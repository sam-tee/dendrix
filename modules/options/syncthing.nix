{
  flake.modules.darwin.options = {
    config,
    lib,
    options,
    pkgs,
    ...
  }: let
    cfg = config.services.syncthing;
    opt = options.services.syncthing;
    defaultUser = "syncthing";
    defaultGroup = defaultUser;
    syncthingUid = 237;
    syncthingGid = 237;
    settingsFormat = pkgs.formats.json {};
    cleanedConfig = lib.converge (lib.filterAttrsRecursive (_: v: v != null && v != {})) cfg.settings;
    isUnixGui = lib.strings.hasPrefix "unix://" cfg.guiAddress;
    curlAddressArgs = path:
      if isUnixGui
      then "--unix-socket ${lib.strings.removePrefix "unix://" cfg.guiAddress} http://syncthing.local${path}"
      else "${cfg.guiAddress}${path}";
    devices = lib.mapAttrsToList (_: device:
      device
      // {
        deviceID = device.id;
      })
    cfg.settings.devices;

    anyAutoAccept = builtins.any (dev: dev.autoAcceptFolders) devices;

    folders = lib.pipe cfg.settings.folders [
      (lib.filterAttrs (_: folder: folder.enable))
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
    grep = lib.getExe pkgs.gnugrep;
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
          if printf %s "$content_type" | ${lib.escapeShellArg grep} -qiP '^text/plain($|([ \t]*;.*))'
          then
            echo Waiting for Syncthing to finish its database migration...
            sleep 30
          elif printf %s "$content_type" | ${lib.escapeShellArg grep} -qiP '^application/json($|([ \t]*;.*))'
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
        lib.pipe
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
          (lib.mapAttrs (
            conf_type: s:
              lib.pipe s.conf [
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
                          devicesWithSecrets = lib.pipe folder.devices [
                            (lib.filter (device: (builtins.isAttrs device) && device ? encryptionPasswordFile))
                            (map (device: {
                              deviceId = device.deviceId;
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
                              device: "--rawfile ${device.variableName} ${lib.escapeShellArg device.secretPath}"
                            )
                            devicesWithSecrets;
                        in "${jq} ${lib.concatStringsSep " " jqRawFiles} ${
                          lib.escapeShellArg (lib.concatStringsSep "|" (["."] ++ jqUpdates))
                        }";
                      }
                    .${
                        conf_type
                      };
                  in
                    ''
                      ${injectSecretsJqCmd} ${jsonPreSecretsFile} | curl --json @- -X POST ${s.baseAddress}
                    ''
                    + lib.optionalString ((conf_type == "dirs") && (new_cfg.ignorePatterns != null)) ''
                      curl -d '{"ignore": ${builtins.toJSON new_cfg.ignorePatterns}}' -X POST ${s.ignoreAddress}?folder=${lib.strings.escapeURL new_cfg.id}
                    ''
                ))
                (lib.concatStringsSep "\n")
              ]
              + lib.optionalString s.override ''
                stale_${conf_type}_ids="$(curl -X GET ${s.baseAddress} | ${jq} \
                  --argjson new_ids ${lib.escapeShellArg (builtins.toJSON s.new_conf_IDs)} \
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
          (lib.concatStringsSep "\n")
        ]
      )
      + (lib.pipe cleanedConfig [
        builtins.attrNames
        (lib.subtractLists [
          "folders"
          "devices"
          "guiPasswordFile"
          "defaults"
        ])
        (map (subOption: ''
          curl -X PATCH -d ${
            lib.escapeShellArg (builtins.toJSON cleanedConfig.${subOption})
          } ${curlAddressArgs "/rest/config/${subOption}"}
        ''))
        (lib.concatStringsSep "\n")
      ])
      + (lib.optionalString (cleanedConfig ? defaults) (
        lib.pipe cleanedConfig.defaults [
          builtins.attrNames
          (map (
            subOption: let
              method =
                if subOption == "ignores"
                then "PUT"
                else "PATCH";
            in ''
              curl -X ${method} -d ${
                lib.escapeShellArg (builtins.toJSON cleanedConfig.defaults.${subOption})
              } ${curlAddressArgs "/rest/config/defaults/${subOption}"}
            ''
          ))
          (lib.concatStringsSep "\n")
        ]
      ))
      + (lib.optionalString (cfg.guiPasswordFile != null) ''
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
        enable = lib.mkEnableOption "Syncthing, a self-hosted open-source alternative to Dropbox and Bittorrent Sync";

        cert = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Path to the `cert.pem` file, which will be copied into Syncthing's
            [configDir](#opt-services.syncthing.configDir).
          '';
        };

        key = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Path to the `key.pem` file, which will be copied into Syncthing's
            [configDir](#opt-services.syncthing.configDir).
          '';
        };

        guiPasswordFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Path to file containing the plaintext password for Syncthing's GUI.
          '';
        };

        overrideDevices = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Whether to delete the devices which are not configured via the
            [devices](#opt-services.syncthing.settings.devices) option.
            If set to `false`, devices added via the web
            interface will persist and will have to be deleted manually.
          '';
        };

        overrideFolders = lib.mkOption {
          type = lib.types.bool;
          default = !anyAutoAccept;
          defaultText = lib.literalMD ''
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

        settings = lib.mkOption {
          type = lib.types.submodule {
            freeformType = settingsFormat.type;
            options = {
              # global options
              options = lib.mkOption {
                default = {};
                description = ''
                  The options element contains all other global configuration options
                '';
                type = lib.types.submodule (
                  {...}: {
                    freeformType = settingsFormat.type;
                    options = {
                      localAnnounceEnabled = lib.mkOption {
                        type = lib.types.nullOr lib.types.bool;
                        default = null;
                        description = ''
                          Whether to send announcements to the local LAN, also use such announcements to find other devices.
                        '';
                      };

                      localAnnouncePort = lib.mkOption {
                        type = lib.types.nullOr lib.types.port;
                        default = null;
                        description = ''
                          The port on which to listen and send IPv4 broadcast announcements to.
                        '';
                      };

                      relaysEnabled = lib.mkOption {
                        type = lib.types.nullOr lib.types.bool;
                        default = null;
                        description = ''
                          When true, relays will be connected to and potentially used for device to device connections.
                        '';
                      };

                      urAccepted = lib.mkOption {
                        type = lib.types.nullOr lib.types.int;
                        default = null;
                        description = ''
                          Whether the user has accepted to submit anonymous usage data.
                          The default, 0, mean the user has not made a choice, and Syncthing will ask at some point in the future.
                          "-1" means no, a number above zero means that that version of usage reporting has been accepted.
                        '';
                      };

                      limitBandwidthInLan = lib.mkOption {
                        type = lib.types.nullOr lib.types.bool;
                        default = null;
                        description = ''
                          Whether to apply bandwidth limits to devices in the same broadcast domain as the local device.
                        '';
                      };

                      maxFolderConcurrency = lib.mkOption {
                        type = lib.types.nullOr lib.types.int;
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

              devices = lib.mkOption {
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
                type = lib.types.attrsOf (
                  lib.types.submodule (
                    {name, ...}: {
                      freeformType = settingsFormat.type;
                      options = {
                        name = lib.mkOption {
                          type = lib.types.str;
                          default = name;
                          description = ''
                            The name of the device.
                          '';
                        };

                        id = lib.mkOption {
                          type = lib.types.str;
                          description = ''
                            The device ID. See <https://docs.syncthing.net/dev/device-ids.html>.
                          '';
                        };

                        autoAcceptFolders = lib.mkOption {
                          type = lib.types.bool;
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

              folders = lib.mkOption {
                default = {};
                description = ''
                  Folders which should be shared by Syncthing.

                  Note that you can still add folders manually, but those changes
                  will be reverted on restart if [overrideFolders](#opt-services.syncthing.overrideFolders)
                  is enabled.
                '';
                example = lib.literalExpression ''
                  {
                    "/home/user/sync" = {
                      id = "syncme";
                      devices = [ "bigbox" ];
                    };
                  }
                '';
                type = lib.types.attrsOf (
                  lib.types.submodule (
                    {name, ...}: {
                      freeformType = settingsFormat.type;
                      options = {
                        enable = lib.mkOption {
                          type = lib.types.bool;
                          default = true;
                          description = ''
                            Whether to share this folder.
                            This option is useful when you want to define all folders
                            in one place, but not every machine should share all folders.
                          '';
                        };

                        path = lib.mkOption {
                          type =
                            lib.types.str
                            // {
                              check = x: lib.types.str.check x && (lib.substring 0 1 x == "/" || lib.substring 0 2 x == "~/");
                              description = lib.types.str.description + " starting with / or ~/";
                            };
                          default = name;
                          description = ''
                            The path to the folder which should be shared.
                            Only absolute paths (starting with `/`) and paths relative to
                            the [user](#opt-services.syncthing.user)'s home directory
                            (starting with `~/`) are allowed.
                          '';
                        };

                        id = lib.mkOption {
                          type = lib.types.str;
                          default = name;
                          description = ''
                            The ID of the folder. Must be the same on all devices.
                          '';
                        };

                        label = lib.mkOption {
                          type = lib.types.str;
                          default = name;
                          description = ''
                            The label of the folder.
                          '';
                        };

                        type = lib.mkOption {
                          type = lib.types.enum [
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

                        devices = lib.mkOption {
                          type = lib.types.listOf (
                            lib.types.oneOf [
                              lib.types.str
                              (lib.types.submodule (
                                {...}: {
                                  freeformType = settingsFormat.type;
                                  options = {
                                    name = lib.mkOption {
                                      type = lib.types.str;
                                      default = null;
                                      description = ''
                                        The name of a device defined in the
                                        [devices](#opt-services.syncthing.settings.devices)
                                        option.
                                      '';
                                    };
                                    encryptionPasswordFile = lib.mkOption {
                                      type = lib.types.nullOr lib.types.externalPath;
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

                        versioning = lib.mkOption {
                          default = null;
                          description = ''
                            How to keep changed/deleted files with Syncthing.
                            There are 4 different types of versioning with different parameters.
                            See <https://docs.syncthing.net/users/versioning.html>.
                          '';
                          example = lib.literalExpression ''
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
                          type = lib.types.nullOr (
                            lib.types.submodule {
                              freeformType = settingsFormat.type;
                              options = {
                                type = lib.mkOption {
                                  type = lib.types.enum [
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

                        copyOwnershipFromParent = lib.mkOption {
                          type = lib.types.bool;
                          default = false;
                          description = ''
                            On Unix systems, tries to copy file/folder ownership from the parent directory (the directory it's located in).
                            Requires running Syncthing as a privileged user, or granting it additional capabilities (e.g. CAP_CHOWN on Linux).
                          '';
                        };

                        ignorePatterns = lib.mkOption {
                          type = lib.types.nullOr (lib.types.listOf lib.types.str);
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

        guiAddress = lib.mkOption {
          type = lib.types.str;
          default = "127.0.0.1:8384";
          apply = x:
            if lib.strings.hasPrefix "/" x
            then "unix://${x}"
            else x;
          description = ''
            The address to serve the web interface at.
          '';
        };

        systemService = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            Whether to auto-launch Syncthing as a system service.
          '';
        };

        user = lib.mkOption {
          type = lib.types.str;
          default = defaultUser;
          example = "yourUser";
          description = ''
            The user to run Syncthing as.
            By default, a user named `${defaultUser}` will be created whose home
            directory is [dataDir](#opt-services.syncthing.dataDir).
          '';
        };

        group = lib.mkOption {
          type = lib.types.str;
          default = defaultGroup;
          example = "yourGroup";
          description = ''
            The group to run Syncthing under.
            By default, a group named `${defaultGroup}` will be created.
          '';
        };

        all_proxy = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "socks5://address.com:1234";
          description = ''
            Overwrites the all_proxy environment variable for the Syncthing process to
            the given value. This is normally used to let Syncthing connect
            through a SOCKS5 proxy server.
            See <https://docs.syncthing.net/users/proxying.html>.
          '';
        };

        dataDir = lib.mkOption {
          type = lib.types.path;
          default = "/var/lib/syncthing";
          example = "/home/yourUser";
          description = ''
            The path where synchronised directories will exist.
          '';
        };

        configDir = lib.mkOption {
          type = lib.types.path;
          description = ''
            The path where the settings and keys will exist.
          '';
          default = cfg.dataDir + "/.config/syncthing";
          defaultText = lib.literalMD ''
            config.${opt.dataDir} + "/.config/syncthing"
          '';
        };

        databaseDir = lib.mkOption {
          type = lib.types.path;
          description = ''
            The directory containing the database and logs.
          '';
          default = cfg.configDir;
          defaultText = lib.literalExpression "config.${opt.configDir}";
        };

        extraFlags = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          example = ["--reset-deltas"];
          description = ''
            Extra flags passed to the syncthing command in the service definition.
          '';
        };

        openDefaultPorts = lib.mkOption {
          type = lib.types.bool;
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

        package = lib.mkPackageOption pkgs "syncthing" {};
      };
    };

    imports =
      [
        (lib.mkRemovedOptionModule ["services" "syncthing" "useInotify"] ''
          This option was removed because Syncthing now has the inotify functionality included under the name "fswatcher".
          It can be enabled on a per-folder basis through the web interface.
        '')
        (
          lib.mkRenamedOptionModule
          ["services" "syncthing" "extraOptions"]
          ["services" "syncthing" "settings"]
        )
        (
          lib.mkRenamedOptionModule
          ["services" "syncthing" "folders"]
          ["services" "syncthing" "settings" "folders"]
        )
        (
          lib.mkRenamedOptionModule
          ["services" "syncthing" "devices"]
          ["services" "syncthing" "settings" "devices"]
        )
        (
          lib.mkRenamedOptionModule
          ["services" "syncthing" "options"]
          ["services" "syncthing" "settings" "options"]
        )
      ]
      ++ map
      (
        o: lib.mkRenamedOptionModule ["services" "syncthing" "declarative" o] ["services" "syncthing" o]
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

    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = !(cfg.overrideFolders && anyAutoAccept);
          message = ''
            services.syncthing.overrideFolders will delete auto-accepted folders
            from the configuration, creating path conflicts.
          '';
        }
        {
          assertion = (lib.hasAttrByPath ["gui" "password"] cfg.settings) -> cfg.guiPasswordFile == null;
          message = ''
            Please use only one of services.syncthing.settings.gui.password or services.syncthing.guiPasswordFile.
          '';
        }
      ];

      warnings = lib.mkIf cfg.openDefaultPorts [
        ''
          services.syncthing.openDefaultPorts is not supported on nix-darwin.
          macOS has no port-based firewall configuration; use the application
          firewall (networking.applicationFirewall) and allow incoming
          connections for the syncthing binary instead.
        ''
      ];

      environment.systemPackages = [cfg.package];

      users.users = lib.mkIf (cfg.systemService && cfg.user == defaultUser) {
        ${defaultUser} = {
          uid = syncthingUid;
          gid = syncthingGid;
          home = cfg.dataDir;
          createHome = true;
          description = "Syncthing daemon user";
        };
      };

      users.groups = lib.mkIf (cfg.systemService && cfg.group == defaultGroup) {
        ${defaultGroup}.gid = syncthingGid;
      };

      system.activationScripts.postActivation = lib.mkIf (cfg.cert != null || cfg.key != null) {
        text = ''
          echo "deploying syncthing certificates..." >&2
          install -dm755 ${lib.escapeShellArg (toString cfg.dataDir)}
          install -dm700 -o ${lib.escapeShellArg cfg.user} -g ${lib.escapeShellArg cfg.group} ${lib.escapeShellArg (toString cfg.configDir)}
          ${lib.optionalString (cfg.cert != null) ''
            install -Dm644 -o ${lib.escapeShellArg cfg.user} -g ${lib.escapeShellArg cfg.group} ${toString cfg.cert} ${cfg.configDir}/cert.pem
          ''}
          ${lib.optionalString (cfg.key != null) ''
            install -Dm600 -o ${lib.escapeShellArg cfg.user} -g ${lib.escapeShellArg cfg.group} ${toString cfg.key} ${cfg.configDir}/key.pem
          ''}
        '';
      };

      launchd.daemons.syncthing = lib.mkIf cfg.systemService {
        environment =
          {
            STNORESTART = "yes";
            STNOUPGRADE = "yes";
          }
          // lib.optionalAttrs (cfg.all_proxy != null) {all_proxy = cfg.all_proxy;};

        command = let
          args = lib.escapeShellArgs (
            (lib.cli.toCommandLineGNU {} {
              "no-browser" = true;
              "gui-address" = cfg.guiAddress;
              "config" = cfg.configDir;
              "data" = cfg.databaseDir;
            })
            ++ cfg.extraFlags
          );
        in "${lib.getExe cfg.package} ${args}";

        serviceConfig = {
          UserName = cfg.user;
          GroupName = cfg.group;
          KeepAlive.SuccessfulExit = false;
          RunAtLoad = true;
        };
      };

      launchd.daemons.syncthing-init = lib.mkIf (cleanedConfig != {} && cfg.systemService) {
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

