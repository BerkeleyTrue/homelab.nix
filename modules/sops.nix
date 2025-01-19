{...}: {
  sops.defaultSopsFile = ../secrets/secrets.yml;
  sops.age = {
    sshKeyPaths = [
      "~/.ssh/id_ed25519"
    ];
    keyFile = "~/.config/sops/age/keys.txt";
  };
  sops.secrets.cloudflare_email = {};
}
