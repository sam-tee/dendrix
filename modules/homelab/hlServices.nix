{
  flake.services = let
    mkService = port: host: private: subdomain: {
      inherit port host private subdomain;
    };
  in {
    anki = mkService 27701 "u410" false "anki";
    atuin = mkService 8888 "u410" false "atuin";
    audiobookshelf = mkService 8000 "" true "audio";
    bazarr = mkService 6767 "u410" true "bazarr";
    caddy = mkService 0 "oracle" true "";
    calibre = mkService 8083 "u410" false "books";
    cockpit = mkService 9090 "u410" true "dash";
    code-server = mkService 4444 "" true "code";
    copyparty = mkService 3210 "u410" true "files";
    forgejo = mkService 3000 "u410" false "git";
    immich = mkService 2283 "u410" false "photos";
    jellyfin = mkService 8096 "u410" false "media";
    lidarr = mkService 8686 "u410" true "lidarr";
    linkwarden = mkService 9183 "u410" false "link";
    mealie = mkService 9876 "u410" false "cooking";
    navidrome = mkService 4533 "u410" false "music";
    nextcloud = mkService 0 "" true "";
    ntfy = mkService 4198 "u410" false "ntfy";
    prowlarr = mkService 9696 "u410" true "prowlarr";
    qbittorrent = mkService 7877 "u410" true "torrent";
    radarr = mkService 7878 "u410" true "radarr";
    seerr = mkService 5055 "u410" true "seerr";
    slskd = mkService 5030 "u410" true "slskd";
    sonarr = mkService 8989 "u410" true "sonarr";
    syncthing = mkService 8384 "u410" true "sync";
    tandoor = mkService 8765 "" true "";
    terraria = mkService 4197 "" false "terraria";
    vaultwarden = mkService 8222 "u410" true "vault";
  };
}
