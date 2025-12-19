let
  theme = builtins.fromTOML (builtins.readFile ./theme.toml);
  template = builtins.readFile ./template.json;
  lib = (import <nixpkgs> {}).lib;
  replacements = {
    "$NAME" = theme.name;
    "AUTHOR" = theme.author;
    "VARIANT" = theme.variant;
    "COLOUR0_" = theme.base00;
    "COLOUR1_" = theme.base01;
    "COLOUR2_" = theme.base02;
    "COLOUR3_" = theme.base03;
    "COLOUR4_" = theme.base04;
    "COLOUR5_" = theme.base05;
    "COLOUR6_" = theme.base06;
    "COLOUR7_" = theme.base07;
    "COLOUR8_" = theme.base08;
    "COLOUR9_" = theme.base09;
    "COLOURA_" = theme.base0A;
    "COLOURB_" = theme.base0B;
    "COLOURC_" = theme.base0C;
    "COLOURD_" = theme.base0D;
    "COLOURE_" = theme.base0E;
    "COLOURF_" = theme.base0F;
  };
in
  builtins.fromJSON (lib.replaceStrings (builtins.attrNames replacements) (builtins.attrValues replacements) template)
