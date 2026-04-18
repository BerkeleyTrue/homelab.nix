{inputs, ...}: let
  sops = {
    defaultSopsFile = ../secrets/secrets.yml;
    age = {
      sshKeyPaths = [
        "/home/bt/.ssh/id_ed25519"
      ];
      keyFile = "/home/bt/.config/sops/age/keys.txt";
    };
  };
in {
  flake.modules.nixos.sops = {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];
    inherit sops;
  };

  flake.modules.homeManager.sops = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
    ];
    inherit sops;
  };
}
