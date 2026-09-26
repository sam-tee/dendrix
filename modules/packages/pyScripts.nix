_: {
  perSystem = {inputs', ...}: {
    inherit (inputs'.pyScripts) packages;
  };
}
