{
  flake.modules.nixos.sunshine = _: {
    services.sunshine = {
      enable = true;
      openFirewall = true;
      settings = {
        capture = "wlr";
        encoder = "quicksync";
        qsv_preset = "veryfast";
        qsv_coder = "cavlc";
        lan_encryption_mode = 0;
        packetsize = 0;
        fec_percentage = 5;
        hevc_mode = 1;
        av1_mode = 1;
        min_threads = 4;
        min_log_level = "info";
        origin_web_ui_allowed = "pc";
      };
    };
  };
}
