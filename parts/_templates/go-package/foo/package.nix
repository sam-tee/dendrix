{
  buildGoModule,
  lib,
}:
buildGoModule {
  pname = "test";
  version = "VERSION_NUMBER";
  src = ./.;
  vendorHash = null;
  #everything below is optional but nice
  meta = {
    description = "PACKAGE_DESCRIPTION";
    homepage = "URL_OF_PACKAGE";
    license = lib.licenses.mit; #change if necessary
  };
}
