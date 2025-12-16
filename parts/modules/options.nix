{lib, ...}:{
  options.dendrix = {
  username = lib.mkOption {
    type = lib.types.str;
    description = "Username for primary accound";
  };
  hostname = lib.mkOption {
    type = lib.types.str;
    description = "hostname for system";
  };
  };
}
