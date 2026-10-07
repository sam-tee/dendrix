{self, ...}: {
  flake.lib.mkService = host: port: subdomain: {
    inherit port host subdomain;
    fqdn =
      if subdomain == ""
      then self.domain
      else "${subdomain}.${self.domain}";
  };
}
