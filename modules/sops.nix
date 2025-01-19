{...}: {
  sops.defaultSopsFile = ../secrets/secrets.yml;
  sops.age = {
    sshKeyPaths = [
      "/home/bt/.ssh/id_ed25519"
    ];
    keyFile = "/home/bt/.config/sops/age/keys.txt";
  };
  sops.secrets.cloudflare_email = {};
}
