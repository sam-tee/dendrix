let
  theme = builtins.fromTOML (builtins.readFile ./theme.toml);
  template = builtins.readFile ./template.json;
  lib = (import <nixpkgs> {}).lib;
  replacements = [
    {
      from = "$NAME";
      to = theme.name;
    }
    {
      from = "$AUTHOR";
      to = theme.author;
    }
    {
      from = "$VARIANT";
      to = theme.variant;
    }
    {
      from = "$COLOUR0_";
      to = theme.base00;
    }
    {
      from = "$COLOUR1_";
      to = theme.base01;
    }
    {
      from = "$COLOUR2_";
      to = theme.base02;
    }
    {
      from = "$COLOUR3_";
      to = theme.base03;
    }
    {
      from = "$COLOUR4_";
      to = theme.base04;
    }
    {
      from = "$COLOUR5_";
      to = theme.base05;
    }
    {
      from = "$COLOUR6_";
      to = theme.base06;
    }
    {
      from = "$COLOUR7_";
      to = theme.base07;
    }
    {
      from = "$COLOUR8_";
      to = theme.base08;
    }
    {
      from = "$COLOUR9_";
      to = theme.base09;
    }
    {
      from = "$COLOURA_";
      to = theme.base0A;
    }
    {
      from = "$COLOURB_";
      to = theme.base0B;
    }
    {
      from = "$COLOURC_";
      to = theme.base0C;
    }
    {
      from = "$COLOURD_";
      to = theme.base0D;
    }
    {
      from = "$COLOURE_";
      to = theme.base0E;
    }
    {
      from = "$COLOURF_";
      to = theme.base0F;
    }
  ];
in
  builtins.fromJSON (lib.replaceStrings (map (r: r.from) replacements) (map (r: r.to) replacements) template)
