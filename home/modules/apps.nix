{pkgs, ...}: let
  gotas = pkgs.buildGoModule rec {
    pname = "gotas";
    version = "0.1.1";

    src = pkgs.fetchFromGitHub {
      owner = "szaffarano";
      repo = "gotas";
      rev = "v${version}";
      hash = "sha256-Gjw1dRrgM8D3G7v6WIM2+50r4HmTXvx0Xxme2fH9TlQ=";
    };

    vendorHash = "sha256-6hCgv2/8UIRHw1kCe3nLkxF23zE/7t5RDwEjSzX3pBQ=";
  };
in {
  home.packages = [
    gotas
  ];
}
