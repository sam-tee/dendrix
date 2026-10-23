_: {
  perSystem = {inputs', ...}: let
    t3code-slim = inputs'.ai.packages.t3code.override {
      providerPackages = with inputs'.ai.packages; [
        claude-code
        opencode2
      ];
    };
    t3code-desktop-slim = inputs'.ai.packages.t3code-desktop.override {
      t3code = t3code-slim;
    };
  in {
    packages = {
      inherit t3code-slim t3code-desktop-slim;
    };
  };
}
