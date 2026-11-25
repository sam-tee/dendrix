_: {
  platformFromOptions = options: {
    isLinux = options ? systemd;
    isDarwin = options ? launchd;
  };
}
