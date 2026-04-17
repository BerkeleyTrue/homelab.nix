{inputs, ...}: {
  flake.modules.nixos.sops = {
    # Include the results of the hardware scan.
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];
    sops.defaultSopsFile = ../secrets/secrets.yml;
    sops.age = {
      sshKeyPaths = [
        "/home/bt/.ssh/id_ed25519"
      ];
      keyFile = "/home/bt/.config/sops/age/keys.txt";
    };
    sops.secrets.cloudflare_email = {};
  };

  flake.modules.homeManager.sops = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}
