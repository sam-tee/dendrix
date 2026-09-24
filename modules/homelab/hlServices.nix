{self, ...}: {
  flake.domain = "samtee.party";
  flake.services = let
    mkService = host: port: subdomain: {
      inherit port host;
      fqdn =
        if subdomain == ""
        then self.domain
        else "${subdomain}.${self.domain}";
    };
  in {
    anki = mkService "oracle" 27701 "anki";
    atticd = mkService "oracle" 27702 "cache";
    atuin = mkService "oracle" 8888 "atuin";
    audiobookshelf = mkService "" 8000 "audio";
    bazarr = mkService "u410" 6767 "bazarr";
    caddy = mkService "oracle" 0 "";
    calibre = mkService "oracle" 8083 "books";
    copyparty = mkService "u410" 3210 "files";
    forgejo = mkService "oracle" 3000 "git";
    home-assistant = mkService "u410" 8123 "ha";
    immich = mkService "u410" 2283 "photos";
    jellyfin = mkService "u410" 8096 "media";
    lidarr = mkService "u410" 8686 "lidarr";
    linkwarden = mkService "u410" 9183 "link";
    mealie = mkService "oracle" 9876 "cooking";
    navidrome = mkService "u410" 4533 "music";
    nextcloud = mkService "" 0 "";
    ntfy = mkService "oracle" 4198 "ntfy";
    prowlarr = mkService "" 9696 "prowlarr";
    qbittorrent = mkService "" 7877 "torrent";
    radarr = mkService "u410" 7878 "radarr";
    seerr = mkService "" 5055 "seerr";
    site = mkService "oracle" 0 "";
    slskd = mkService "u410" 5030 "slskd";
    sonarr = mkService "u410" 8989 "sonarr";
    sports-ntfy = mkService "oracle" 0 "";
    vaultwarden = mkService "oracle" 8222 "vault";
  };
}
