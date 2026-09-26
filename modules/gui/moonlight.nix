{
  flake.modules.nixos.moonlight = _: {
    programs.moonlight-qt = {
      enable = true;
      capSysNice = true;
    };
  };
}
