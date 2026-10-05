{self, ...}: {
  flake.lib.mkService = host: port: subdomain: {
    inherit port host;
    fqdn =
      if subdomain == ""
      then self.domain
      else "${subdomain}.${self.domain}";
  };
}
