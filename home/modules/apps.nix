{
  pkgs,
  ...
}: let
  gotas = pkgs.buildGoModule {
    pname = "gotas";
    version = "0.1.1";

    src = pkgs.fetchFromGitHub {
      owner = "szaffarano";
      repo = "gotas";
      rev = "12933a2f5a1eaa07b520b96184198724706a6ab6";
      hash = "sha256-VduHspo/DnZN8ux9qcpi9jefNUBGOdzZmhbm1gYxG60=";
    };

    vendorHash = "sha256-s7P9cproB1gxjAwpS6NPMOb/rIaNLZQjoTToB7jvOuc=";
  };
in {
  home.packages = [
    gotas
  ];
}
