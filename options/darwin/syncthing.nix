# mirror nixpkgs nixos module for darwin
{
  flake.modules.darwin.options = {
    config,
    lib,
    options,
    pkgs,
    ...
  }: let
    inherit (lib) concatStringsSep converge escapeShellArg escapeShellArgs filter filterAttrs filterAttrsRecursive getExe hasAttrByPath literalExpression literalMD mapAttrs mapAttrsToList mkEnableOption mkIf mkOption mkPackageOption mkRemovedOptionModule mkRenamedOptionModule optionalAttrs optionalString pipe substring subtractLists;
    inherit (lib.cli) toCommandLineGNU;
    inherit (lib.strings) escapeURL hasPrefix removePrefix;
    inherit (lib.types) attrsOf bool enum externalPath int listOf nullOr oneOf path port str submodule;
    cfg = config.services.syncthing;
    opt = options.services.syncthing;
    defaultUser = "syncthing";
    defaultGroup = defaultUser;
    syncthingUid = 237;
    syncthingGid = 237;
    settingsFormat = pkgs.formats.json {};
    cleanedConfig = converge (filterAttrsRecursive (_: v: v != null && v != {})) cfg.settings;
    isUnixGui = hasPrefix "unix://" cfg.guiAddress;
    curlAddressArgs = path:
      if isUnixGui
      then "--unix-socket ${removePrefix "unix://" cfg.guiAddress} http://syncthing.local${path}"
      else "${cfg.guiAddress}${path}";
    devices = mapAttrsToList (_: device:
      device
      // {
        deviceID = device.id;
      })
    cfg.settings.devices;

    anyAutoAccept = builtins.any (dev: dev.autoAcceptFolders) devices;

    folders = pipe cfg.settings.folders [
      (filterAttrs (_: folder: folder.enable))
      builtins.attrValues
      (map (
        folder:
          folder
          // {
            devices =
              map (
                device:
                  if builtins.isString device
                  then {deviceId = cfg.settings.devices.${device}.id;}
                  else {deviceId = cfg.settings.devices.${device.name}.id;} // device
              )
              folder.devices;
          }
      ))
    ];

    jq = "${pkgs.jq}/bin/jq";
    grep = getExe pkgs.gnugrep;
    updateConfig = pkgs.writers.writeBash "merge-syncthing-config" (
      ''
        set -efu
        umask 0077
        curl() {
            while
                ! ${pkgs.libxml2}/bin/xmllint \
                    --xpath 'string(configuration/gui/apikey)' \
                    ${cfg.configDir}/config.xml \
                    >"$RUNTIME_DIRECTORY/api_key"
            do sleep 1; done
            (printf "X-API-Key: "; cat "$RUNTIME_DIRECTORY/api_key") >"$RUNTIME_DIRECTORY/headers"
            ${pkgs.curl}/bin/curl -sSLk -H "@$RUNTIME_DIRECTORY/headers" \
                --retry 1000 --retry-delay 1 --retry-all-errors \
                "$@"
        }
        while true
        do
          content_type="$(curl \
            -o /dev/null \
            -w '%header{Content-Type}' \
            ${curlAddressArgs "/rest/noauth/health"}
          )"
          if printf %s "$content_type" | ${escapeShellArg grep} -qiP '^text/plain($|([ \t]*;.*))'
          then
            echo Waiting for Syncthing to finish its database migration...
            sleep 30
          elif printf %s "$content_type" | ${escapeShellArg grep} -qiP '^application/json($|([ \t]*;.*))'
          then
            echo 'Syncthing is not doing a database migration (anymore).'
            break
          else
            printf 'ERROR: Syncthing responded with an unexpected Content-Type: %s\n' "$content_type"
            # This is the EX_PROTOCOL exit status from <man:sysexits.h(3head)>.
            exit 76
          fi
        done
      ''
      + (
        pipe
        {
          devs = {
            new_conf_IDs = map (v: v.id) devices;
            GET_IdAttrName = "deviceID";
            override = cfg.overrideDevices;
            conf = devices;
            baseAddress = curlAddressArgs "/rest/config/devices";
          };
          dirs = {
            new_conf_IDs = map (v: v.id) folders;
            GET_IdAttrName = "id";
            override = cfg.overrideFolders;
            conf = folders;
            baseAddress = curlAddressArgs "/rest/config/folders";
            ignoreAddress = curlAddressArgs "/rest/db/ignores";
          };
        }
        [
          (mapAttrs (
            conf_type: s:
              pipe s.conf [
                (map (
                  new_cfg: let
                    jsonPreSecretsFile = pkgs.writeTextFile {
                      name = "${conf_type}-${new_cfg.id}-conf-pre-secrets.json";
                      text = builtins.toJSON (removeAttrs new_cfg ["ignorePatterns"]);
                    };
                    injectSecretsJqCmd =
                      {
                        "devs" = "${jq} .";
                        "dirs" = let
                          folder = new_cfg;
                          devicesWithSecrets = pipe folder.devices [
                            (filter (device: (builtins.isAttrs device) && device ? encryptionPasswordFile))
                            (map (device: {
                              inherit (device) deviceId;
                              variableName = "secret_${builtins.hashString "sha256" device.encryptionPasswordFile}";
                              secretPath = device.encryptionPasswordFile;
                            }))
                          ];
                          jqUpdates =
                            map (device: ''
                              .devices[] |= (
                                if .deviceId == "${device.deviceId}" then
                                  del(.encryptionPasswordFile) |
                                  .encryptionPassword = ''$${device.variableName}
                                else
                                  .
                                end
                              )
                            '')
                            devicesWithSecrets;
                          jqRawFiles =
                            map (
                              device: "--rawfile ${device.variableName} ${escapeShellArg device.secretPath}"
                            )
                            devicesWithSecrets;
                        in "${jq} ${concatStringsSep " " jqRawFiles} ${
                          escapeShellArg (concatStringsSep "|" (["."] ++ jqUpdates))
                        }";
                      }
                    .${
                        conf_type
                      };
                  in
                    ''
                      ${injectSecretsJqCmd} ${jsonPreSecretsFile} | curl --json @- -X POST ${s.baseAddress}
                    ''
                    + optionalString ((conf_type == "dirs") && (new_cfg.ignorePatterns != null)) ''
                      curl -d '{"ignore": ${builtins.toJSON new_cfg.ignorePatterns}}' -X POST ${s.ignoreAddress}?folder=${escapeURL new_cfg.id}
                    ''
                ))
                (concatStringsSep "\n")
              ]
              + optionalString s.override ''
                stale_${conf_type}_ids="$(curl -X GET ${s.baseAddress} | ${jq} \
                  --argjson new_ids ${escapeShellArg (builtins.toJSON s.new_conf_IDs)} \
                  --raw-output \
                  '[.[].${s.GET_IdAttrName}] - $new_ids | .[]|@uri'
                )"
                for id in ''${stale_${conf_type}_ids}; do
                  >&2 echo "Deleting stale device: $id"
                  curl -X DELETE ${s.baseAddress}/$id
                done
              ''
          ))
          builtins.attrValues
          (concatStringsSep "\n")
        ]
      )
      + (pipe cleanedConfig [
        builtins.attrNames
        (subtractLists [
          "folders"
          "devices"
          "guiPasswordFile"
          "defaults"
        ])
        (map (subOption: ''
          curl -X PATCH -d ${
            escapeShellArg (builtins.toJSON cleanedConfig.${subOption})
          } ${curlAddressArgs "/rest/config/${subOption}"}
        ''))
        (concatStringsSep "\n")
      ])
      + (optionalString (cleanedConfig ? defaults) (
        pipe cleanedConfig.defaults [
          builtins.attrNames
          (map (
            subOption: let
              method =
                if subOption == "ignores"
                then "PUT"
                else "PATCH";
            in ''
              curl -X ${method} -d ${
                escapeShellArg (builtins.toJSON cleanedConfig.defaults.${subOption})
              } ${curlAddressArgs "/rest/config/defaults/${subOption}"}
            ''
          ))
          (concatStringsSep "\n")
        ]
      ))
      + (optionalString (cfg.guiPasswordFile != null) ''
        ${pkgs.mkpasswd}/bin/mkpasswd -m bcrypt --stdin <"${cfg.guiPasswordFile}" | tr -d "\n" > "$RUNTIME_DIRECTORY/password_bcrypt"
        curl -X PATCH --variable "pw_bcrypt@$RUNTIME_DIRECTORY/password_bcrypt" --expand-json '{ "password": "{{pw_bcrypt}}" }' ${curlAddressArgs "/rest/config/gui"}
      '')
      + ''
        # restart Syncthing if required
        if curl ${curlAddressArgs "/rest/config/restart-required"} |
           ${jq} -e .requiresRestart > /dev/null; then
            curl -X POST ${curlAddressArgs "/rest/system/restart"}
        fi
      ''
    );

    syncthingInitScript = pkgs.writers.writeBash "syncthing-init" ''
      set -efu

      runDir="$(mktemp -d "/tmp/syncthing-init.XXXXXX")"
      trap 'rm -rf "$runDir"' EXIT INT TERM
      export RUNTIME_DIRECTORY="$runDir"

      exec ${updateConfig}
    '';
  in {
    options = {
      services.syncthing = {
        enable = mkEnableOption "Syncthing, a self-hosted open-source alternative to Dropbox and Bittorrent Sync";

        cert = mkOption {
          type = nullOr str;
          default = null;
          description = ''
            Path to the `cert.pem` file, which will be copied into Syncthing's
            [configDir](#opt-services.syncthing.configDir).
          '';
        };

        key = mkOption {
          type = nullOr str;
          default = null;
          description = ''
            Path to the `key.pem` file, which will be copied into Syncthing's
            [configDir](#opt-services.syncthing.configDir).
          '';
        };

        guiPasswordFile = mkOption {
          type = nullOr str;
          default = null;
          description = ''
            Path to file containing the plaintext password for Syncthing's GUI.
          '';
        };

        overrideDevices = mkOption {
          type = bool;
          default = true;
          description = ''
            Whether to delete the devices which are not configured via the
            [devices](#opt-services.syncthing.settings.devices) option.
            If set to `false`, devices added via the web
            interface will persist and will have to be deleted manually.
          '';
        };

        overrideFolders = mkOption {
          type = bool;
          default = !anyAutoAccept;
          defaultText = literalMD ''
            `true` unless any device has the
            [autoAcceptFolders](#opt-services.syncthing.settings.devices._name_.autoAcceptFolders)
            option set to `true`.
          '';
          description = ''
            Whether to delete the folders which are not configured via the
            [folders](#opt-services.syncthing.settings.folders) option.
            If set to `false`, folders added via the web
            interface will persist and will have to be deleted manually.
          '';
        };

        settings = mkOption {
          type = submodule {
            freeformType = settingsFormat.type;
            options = {
              # global options
              options = mkOption {
                default = {};
                description = ''
                  The options element contains all other global configuration options
                '';
                type = submodule (
                  _: {
                    freeformType = settingsFormat.type;
                    options = {
                      localAnnounceEnabled = mkOption {
                        type = nullOr bool;
                        default = null;
                        description = ''
                          Whether to send announcements to the local LAN, also use such announcements to find other devices.
                        '';
                      };

                      localAnnouncePort = mkOption {
                        type = nullOr port;
                        default = null;
                        description = ''
                          The port on which to listen and send IPv4 broadcast announcements to.
                        '';
                      };

                      relaysEnabled = mkOption {
                        type = nullOr bool;
                        default = null;
                        description = ''
                          When true, relays will be connected to and potentially used for device to device connections.
                        '';
                      };

                      urAccepted = mkOption {
                        type = nullOr int;
                        default = null;
                        description = ''
                          Whether the user has accepted to submit anonymous usage data.
                          The default, 0, mean the user has not made a choice, and Syncthing will ask at some point in the future.
                          "-1" means no, a number above zero means that that version of usage reporting has been accepted.
                        '';
                      };

                      limitBandwidthInLan = mkOption {
                        type = nullOr bool;
                        default = null;
                        description = ''
                          Whether to apply bandwidth limits to devices in the same broadcast domain as the local device.
                        '';
                      };

                      maxFolderConcurrency = mkOption {
                        type = nullOr int;
                        default = null;
                        description = ''
                          This option controls how many folders may concurrently be in I/O-intensive operations such as syncing or scanning.
                          The mechanism is described in detail in a [separate chapter](https://docs.syncthing.net/advanced/option-max-concurrency.html).
                        '';
                      };
                    };
                  }
                );
              };

              devices = mkOption {
                default = {};
                description = ''
                  Peers/devices which Syncthing should communicate with.

                  Note that you can still add devices manually, but those changes
                  will be reverted on restart if [overrideDevices](#opt-services.syncthing.overrideDevices)
                  is enabled.
                '';
                example = {
                  bigbox = {
                    id = "7CFNTQM-IMTJBHJ-3UWRDIU-ZGQJFR6-VCXZ3NB-XUH3KZO-N52ITXR-LAIYUAU";
                    addresses = ["tcp://192.168.0.10:51820"];
                  };
                };
                type = attrsOf (
                  submodule (
                    {name, ...}: {
                      freeformType = settingsFormat.type;
                      options = {
                        name = mkOption {
                          type = str;
                          default = name;
                          description = ''
                            The name of the device.
                          '';
                        };

                        id = mkOption {
                          type = str;
                          description = ''
                            The device ID. See <https://docs.syncthing.net/dev/device-ids.html>.
                          '';
                        };

                        autoAcceptFolders = mkOption {
                          type = bool;
                          default = false;
                          description = ''
                            Automatically create or share folders that this device advertises at the default path.
                            See <https://docs.syncthing.net/users/config.html?highlight=autoaccept#config-file-format>.
                          '';
                        };
                      };
                    }
                  )
                );
              };

              folders = mkOption {
                default = {};
                description = ''
                  Folders which should be shared by Syncthing.

                  Note that you can still add folders manually, but those changes
                  will be reverted on restart if [overrideFolders](#opt-services.syncthing.overrideFolders)
                  is enabled.
                '';
                example = literalExpression ''
                  {
                    "/home/user/sync" = {
                      id = "syncme";
                      devices = [ "bigbox" ];
                    };
                  }
                '';
                type = attrsOf (
                  submodule (
                    {name, ...}: {
                      freeformType = settingsFormat.type;
                      options = {
                        enable = mkOption {
                          type = bool;
                          default = true;
                          description = ''
                            Whether to share this folder.
                            This option is useful when you want to define all folders
                            in one place, but not every machine should share all folders.
                          '';
                        };

                        path = mkOption {
                          type =
                            str
                            // {
                              check = x: str.check x && (substring 0 1 x == "/" || substring 0 2 x == "~/");
                              description = str.description + " starting with / or ~/";
                            };
                          default = name;
                          description = ''
                            The path to the folder which should be shared.
                            Only absolute paths (starting with `/`) and paths relative to
                            the [user](#opt-services.syncthing.user)'s home directory
                            (starting with `~/`) are allowed.
                          '';
                        };

                        id = mkOption {
                          type = str;
                          default = name;
                          description = ''
                            The ID of the folder. Must be the same on all devices.
                          '';
                        };

                        label = mkOption {
                          type = str;
                          default = name;
                          description = ''
                            The label of the folder.
                          '';
                        };

                        type = mkOption {
                          type = enum [
                            "sendreceive"
                            "sendonly"
                            "receiveonly"
                            "receiveencrypted"
                          ];
                          default = "sendreceive";
                          description = ''
                            Controls how the folder is handled by Syncthing.
                            See <https://docs.syncthing.net/users/config.html#config-option-folder.type>.
                          '';
                        };

                        devices = mkOption {
                          type = listOf (
                            oneOf [
                              str
                              (submodule (
                                _: {
                                  freeformType = settingsFormat.type;
                                  options = {
                                    name = mkOption {
                                      type = str;
                                      default = null;
                                      description = ''
                                        The name of a device defined in the
                                        [devices](#opt-services.syncthing.settings.devices)
                                        option.
                                      '';
                                    };
                                    encryptionPasswordFile = mkOption {
                                      type = nullOr externalPath;
                                      default = null;
                                      description = ''
                                        Path to encryption password. If set, the file will be read during
                                        service activation, without being embedded in derivation.
                                      '';
                                    };
                                  };
                                }
                              ))
                            ]
                          );
                          default = [];
                          description = ''
                            The devices this folder should be shared with. Each device must
                            be defined in the [devices](#opt-services.syncthing.settings.devices) option.

                            A list of either strings or attribute sets, where values
                            are device names or device configurations.
                          '';
                        };

                        versioning = mkOption {
                          default = null;
                          description = ''
                            How to keep changed/deleted files with Syncthing.
                            There are 4 different types of versioning with different parameters.
                            See <https://docs.syncthing.net/users/versioning.html>.
                          '';
                          example = literalExpression ''
                            [
                              {
                                versioning = {
                                  type = "simple";
                                  params.keep = "10";
                                };
                              }
                              {
                                versioning = {
                                  type = "trashcan";
                                  params.cleanoutDays = "1000";
                                };
                              }
                              {
                                versioning = {
                                  type = "staggered";
                                  fsPath = "/syncthing/backup";
                                  params = {
                                    cleanInterval = "3600";
                                    maxAge = "31536000";
                                  };
                                };
                              }
                              {
                                versioning = {
                                  type = "external";
                                  params.versionsPath = pkgs.writers.writeBash "backup" '''
                                    folderpath="$1"
                                    filepath="$2"
                                    rm -rf "$folderpath/$filepath"
                                  ''';
                                };
                              }
                            ]
                          '';
                          type = nullOr (
                            submodule {
                              freeformType = settingsFormat.type;
                              options = {
                                type = mkOption {
                                  type = enum [
                                    "external"
                                    "simple"
                                    "staggered"
                                    "trashcan"
                                  ];
                                  description = ''
                                    The type of versioning.
                                    See <https://docs.syncthing.net/users/versioning.html>.
                                  '';
                                };
                              };
                            }
                          );
                        };

                        copyOwnershipFromParent = mkOption {
                          type = bool;
                          default = false;
                          description = ''
                            On Unix systems, tries to copy file/folder ownership from the parent directory (the directory it's located in).
                            Requires running Syncthing as a privileged user, or granting it additional capabilities (e.g. CAP_CHOWN on Linux).
                          '';
                        };

                        ignorePatterns = mkOption {
                          type = nullOr (listOf str);
                          default = null;
                          description = ''
                            Syncthing can be configured to ignore certain files in a folder using ignore patterns.
                            Enter them as a list of strings, one string per line.
                            See the Syncthing documentation for syntax: <https://docs.syncthing.net/users/ignoring.html>
                            Patterns set using the WebUI will be overridden if you define this option.
                            If you want to override the ignore patterns to be empty, use `ignorePatterns = []`.
                            Deleting the `ignorePatterns` option will not remove the patterns from Syncthing automatically
                            because patterns are only handled by the module if this option is defined. Either use
                            `ignorePatterns = []` before deleting the option or remove the patterns afterwards using the WebUI.
                          '';
                          example = [
                            "// This is a comment"
                            "*.part // Firefox downloads and other things"
                            "*.crdownload // Chrom(ium|e) downloads"
                          ];
                        };
                      };
                    }
                  )
                );
              };
            };
          };
          default = {};
          description = ''
            Extra configuration options for Syncthing.
            See <https://docs.syncthing.net/users/config.html>.
            Note that this attribute set does not exactly match the documented
            xml format. Instead, this is the format of the json rest api. There
            are slight differences. For example, this xml:
            ```xml
            <options>
              <listenAddress>default</listenAddress>
              <minHomeDiskFree unit="%">1</minHomeDiskFree>
            </options>
            ```
            corresponds to the json:
            ```json
            {
              options: {
                listenAddresses = [
                  "default"
                ];
                minHomeDiskFree = {
                  unit = "%";
                  value = 1;
                };
              };
            }
            ```
          '';
          example = {
            options.localAnnounceEnabled = false;
            gui.theme = "black";
          };
        };

        guiAddress = mkOption {
          type = str;
          default = "127.0.0.1:8384";
          apply = x:
            if hasPrefix "/" x
            then "unix://${x}"
            else x;
          description = ''
            The address to serve the web interface at.
          '';
        };

        systemService = mkOption {
          type = bool;
          default = true;
          description = ''
            Whether to auto-launch Syncthing as a system service.
          '';
        };

        user = mkOption {
          type = str;
          default = defaultUser;
          example = "yourUser";
          description = ''
            The user to run Syncthing as.
            By default, a user named `${defaultUser}` will be created whose home
            directory is [dataDir](#opt-services.syncthing.dataDir).
          '';
        };

        group = mkOption {
          type = str;
          default = defaultGroup;
          example = "yourGroup";
          description = ''
            The group to run Syncthing under.
            By default, a group named `${defaultGroup}` will be created.
          '';
        };

        all_proxy = mkOption {
          type = nullOr str;
          default = null;
          example = "socks5://address.com:1234";
          description = ''
            Overwrites the all_proxy environment variable for the Syncthing process to
            the given value. This is normally used to let Syncthing connect
            through a SOCKS5 proxy server.
            See <https://docs.syncthing.net/users/proxying.html>.
          '';
        };

        dataDir = mkOption {
          type = path;
          default = "/var/lib/syncthing";
          example = "/home/yourUser";
          description = ''
            The path where synchronised directories will exist.
          '';
        };

        configDir = mkOption {
          type = path;
          description = ''
            The path where the settings and keys will exist.
          '';
          default = cfg.dataDir + "/.config/syncthing";
          defaultText = literalMD ''
            config.${opt.dataDir} + "/.config/syncthing"
          '';
        };

        databaseDir = mkOption {
          type = path;
          description = ''
            The directory containing the database and logs.
          '';
          default = cfg.configDir;
          defaultText = literalExpression "config.${opt.configDir}";
        };

        extraFlags = mkOption {
          type = listOf str;
          default = [];
          example = ["--reset-deltas"];
          description = ''
            Extra flags passed to the syncthing command in the service definition.
          '';
        };

        openDefaultPorts = mkOption {
          type = bool;
          default = false;
          example = true;
          description = ''
            Whether to open the default ports in the firewall: TCP/UDP 22000 for transfers
            and UDP 21027 for discovery.

            If multiple users are running Syncthing on this machine, you will need
            to manually open a set of ports for each instance and leave this disabled.
            Alternatively, if you are running only a single instance on this machine
            using the default ports, enable this.
          '';
        };

        package = mkPackageOption pkgs "syncthing" {};
      };
    };

    imports =
      [
        (mkRemovedOptionModule ["services" "syncthing" "useInotify"] ''
          This option was removed because Syncthing now has the inotify functionality included under the name "fswatcher".
          It can be enabled on a per-folder basis through the web interface.
        '')
        (
          mkRenamedOptionModule
          ["services" "syncthing" "extraOptions"]
          ["services" "syncthing" "settings"]
        )
        (
          mkRenamedOptionModule
          ["services" "syncthing" "folders"]
          ["services" "syncthing" "settings" "folders"]
        )
        (
          mkRenamedOptionModule
          ["services" "syncthing" "devices"]
          ["services" "syncthing" "settings" "devices"]
        )
        (
          mkRenamedOptionModule
          ["services" "syncthing" "options"]
          ["services" "syncthing" "settings" "options"]
        )
      ]
      ++ map
      (
        o: mkRenamedOptionModule ["services" "syncthing" "declarative" o] ["services" "syncthing" o]
      )
      [
        "cert"
        "key"
        "devices"
        "folders"
        "overrideDevices"
        "overrideFolders"
        "extraOptions"
      ];

    config = mkIf cfg.enable {
      assertions = [
        {
          assertion = !(cfg.overrideFolders && anyAutoAccept);
          message = ''
            services.syncthing.overrideFolders will delete auto-accepted folders
            from the configuration, creating path conflicts.
          '';
        }
        {
          assertion = (hasAttrByPath ["gui" "password"] cfg.settings) -> cfg.guiPasswordFile == null;
          message = ''
            Please use only one of services.syncthing.settings.gui.password or services.syncthing.guiPasswordFile.
          '';
        }
      ];

      warnings = mkIf cfg.openDefaultPorts [
        ''
          services.syncthing.openDefaultPorts is not supported on nix-darwin.
          macOS has no port-based firewall configuration; use the application
          firewall (networking.applicationFirewall) and allow incoming
          connections for the syncthing binary instead.
        ''
      ];

      environment.systemPackages = [cfg.package];

      users.users = mkIf (cfg.systemService && cfg.user == defaultUser) {
        ${defaultUser} = {
          uid = syncthingUid;
          gid = syncthingGid;
          home = cfg.dataDir;
          createHome = true;
          description = "Syncthing daemon user";
        };
      };

      users.groups = mkIf (cfg.systemService && cfg.group == defaultGroup) {
        ${defaultGroup}.gid = syncthingGid;
      };

      system.activationScripts.postActivation = mkIf (cfg.cert != null || cfg.key != null) {
        text = ''
          echo "deploying syncthing certificates..." >&2
          install -dm755 ${escapeShellArg (toString cfg.dataDir)}
          install -dm700 -o ${escapeShellArg cfg.user} -g ${escapeShellArg cfg.group} ${escapeShellArg (toString cfg.configDir)}
          ${optionalString (cfg.cert != null) ''
            install -Dm644 -o ${escapeShellArg cfg.user} -g ${escapeShellArg cfg.group} ${toString cfg.cert} ${cfg.configDir}/cert.pem
          ''}
          ${optionalString (cfg.key != null) ''
            install -Dm600 -o ${escapeShellArg cfg.user} -g ${escapeShellArg cfg.group} ${toString cfg.key} ${cfg.configDir}/key.pem
          ''}
        '';
      };

      launchd.daemons.syncthing = mkIf cfg.systemService {
        environment =
          {
            STNORESTART = "yes";
            STNOUPGRADE = "yes";
          }
          // optionalAttrs (cfg.all_proxy != null) {inherit (cfg) all_proxy;};

        command = let
          args = escapeShellArgs (
            (toCommandLineGNU {} {
              "no-browser" = true;
              "gui-address" = cfg.guiAddress;
              "config" = cfg.configDir;
              "data" = cfg.databaseDir;
            })
            ++ cfg.extraFlags
          );
        in "${getExe cfg.package} ${args}";

        serviceConfig = {
          UserName = cfg.user;
          GroupName = cfg.group;
          KeepAlive.SuccessfulExit = false;
          RunAtLoad = true;
        };
      };

      launchd.daemons.syncthing-init = mkIf (cleanedConfig != {} && cfg.systemService) {
        command = syncthingInitScript;
        serviceConfig = {
          UserName = cfg.user;
          GroupName = cfg.group;
          RunAtLoad = true;
          KeepAlive = false;
        };
      };
    };
  };
}
