{self, ...}: let
  inherit (self.lib) mkPublicService mkService;
in {
  flake = {
    domain = "samtee.party";
    tailnet = "scylla-goblin.ts.net";
    services = {
      anki = mkService "oracle" 27701 "anki";
      atticd = mkPublicService "oracle" 27702 "cache";
      atuin = mkService "oracle" 8888 "atuin";
      audiobookshelf = mkService "" 8000 "audio";
      bazarr = mkService "u410" 6767 "bazarr";
      caddy = mkService "oracle" 0 "";
      calibre-web = mkPublicService "oracle" 8083 "books";
      cliproxyapi = mkService "u410" 8037 "ai";
      copyparty = mkService "u410" 3210 "files";
      forgejo = mkPublicService "oracle" 3000 "git";
      home-assistant = mkService "u410" 8123 "ha";
      immich = mkPublicService "u410" 2283 "photos";
      jellyfin = mkPublicService "u410" 8096 "media";
      lidarr = mkService "u410" 8686 "lidarr";
      linkwarden = mkService "u410" 9183 "link";
      mealie = mkPublicService "oracle" 9876 "cooking";
      navidrome = mkPublicService "u410" 4533 "music";
      nextcloud = mkService "" 0 "";
      ntfy = mkPublicService "oracle" 4198 "ntfy";
      prowlarr = mkService "" 9696 "prowlarr";
      qbittorrent = mkService "" 7877 "torrent";
      radarr = mkService "u410" 7878 "radarr";
      seerr = mkService "" 5055 "seerr";
      share = mkService "oracle" 0 "share";
      site = mkService "oracle" 0 "";
      slskd = mkService "u410" 5030 "slskd";
      sonarr = mkService "u410" 8989 "sonarr";
      sports-ntfy = mkPublicService "oracle" 0 "";
      t3 = mkService "oracle" 3773 "t3";
      vaultwarden = mkService "oracle" 8222 "vault";
    };
  };
}
