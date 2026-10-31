{self, ...}: {
  flake.lib = rec {
    mkGenericService = isPublic: host: port: subdomain: {
      inherit port host subdomain;
      tailnetOnly = !isPublic;
      fqdn =
        if subdomain == ""
        then self.domain
        else "${subdomain}.${self.domain}";
    };
    mkService = mkGenericService false;
    mkPublicService = mkGenericService true;
  };
}
