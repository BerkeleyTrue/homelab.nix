{...}: {
  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];

      # avoid unwanted garbage collection
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = false;
    };
  };
}
