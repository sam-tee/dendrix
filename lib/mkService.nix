{
  lib,
  self,
  ...
}: {
  mkGenericService = isPublic: host: port: subdomain: {
    inherit port host subdomain;
    tailnetOnly = !isPublic;
    fqdn =
      if subdomain == ""
      then self.domain
      else "${subdomain}.${self.domain}";
  };
  mkService = lib.mkGenericService false;
  mkPublicService = lib.mkGenericService true;
}
