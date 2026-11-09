{
  inputs = {
    aeroswipe = {
      url = "git+https://git.samtee.party/sam-tee/aeroswipe.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cliproxy-usage-ntfy = {
      url = "git+https://git.samtee.party/sam-tee/cliproxy-usage-ntfy.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-py = {
      url = "git+https://git.samtee.party/sam-tee/deploy-py.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    helium = {
      url = "github:amaanq/helium-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    iio-hyprland = {
      url = "github:ThorTuwy/lua-iio-hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mobile-nixos = {
      url = "git+https://git.samtee.party/sam-tee/mobile.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nhw = {
      url = "git+https://git.samtee.party/sam-tee/nhw.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
        niri-stable.follows = "niri-flake/niri-unstable";
        xwayland-satellite-stable.follows = "niri-flake/xwayland-satellite-unstable";
      };
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    nixpkgs-pr-tracker = {
      url = "git+https://git.samtee.party/sam-tee/nixpkgs-pr-tracker.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    paneru = {
      url = "github:karinushka/paneru";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-darwin.follows = "nix-darwin";
        flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
      };
    };
    searchix = {
      url = "git+https://git.samtee.party/sam-tee/searchix.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sports-ntfy = {
      url = "git+https://git.samtee.party/sam-tee/sports-ntfy.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    inherit (import ./lib/importTree.nix {}) importTree;
    lib = inputs.nixpkgs.lib.extend (final: _:
      importTree ./lib
      |> map (file:
        import file {
          lib = final;
          inherit inputs;
          inherit (inputs) self;
        })
      |> builtins.foldl' (acc: helpers: acc // helpers) {});
  in
    inputs.flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {inherit lib;};
    } {
      imports = importTree [./hosts ./modules ./options ./vars];
    };
}
