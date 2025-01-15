{...}: {
  services.podman = {
    enable = true;
  };

  services.taskchampion-sync-server = {
    enable = true;
    dataDir = "/mnt/storage/taskchampion";
  };
}
