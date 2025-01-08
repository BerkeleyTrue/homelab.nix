{pkgs, ...}: let
  bat-catppucchin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "bat";
    rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
    sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
  };
in {
  home.packages = with pkgs; [
    antigen # zsh plugin manager
    babashka # A Clojure babushka for the grey areas of bash
    bind # dns client
    bottom # A cross-platform graphical process/system monitor with a customizable interface and a multitude of features
    curl # transfer data from or to a server
    dogdns # A command-line DNS cliento
    du-dust # A more intuitive version of du in rust
    eza # A modern replacement for ls
    fd # A simple, fast and user-friendly alternative to find
    fzf # A command-line fuzzy finder
    gh # GitHub CLI
    htop # An interactive process viewer
    iputils # Network monitoring tools including ping
    lazydocker # simple terminal ui for both docker and docker-compose
    lsof # lists open files
    ngrok # Introspected tunnels to localhost
    p7zip # 7-Zip is a file archiver with a high compression ratio
    playerctl # pause/play music players ci
    podman # A program for managing pods, containers and container images
    podman-tui # Podman Terminal UI
    podman-compose # A tool for running docker-compose.yml using podman
    procs # A modern replacement for ps written in Rust
    ripgrep # recursively searches directories for a regex pattern
    rsync # Fast incremental file transfer utility
    rustscan # The Modern Port Scanner
    shfmt # A shell parser, formatter, and interpreter (POSIX/Bash/mksh)
    silver-searcher # A code-searching tool similar to ack, but faster
    tealdeer # A very fast implementation of tldr in Rust
    traceroute # print the route packets trace to network host
    udisks # access and manipulate disks and media devices
    vimv # batch rename files w/ vim
    wget # The non-interactive network downloader # required by jdownloader
    zoxide # A fast alternative to cd that learns your habits
    zsh # A shell designed for interactive use, although it is also a powerful scripting language
  ];

  xdg.configFile."containers/registries.conf".text = ''
    unqualified-search-registries = ["docker.io"]

    [[registry]]
    prefix = "docker.io"
    insecure = false
    blocked = false
    location = "docker.io"
  '';

  programs = {
    # A cat(1) clone with wings
    bat = {
      enable = true;

      config = {
        theme = "catppuccin";
        map-syntax = [
          "*.fnl:Clojure"
          "*.templ:Go"
          "flake.lock:JSON"
        ];
      };

      themes = {
        catppuccin = {
          src = bat-catppucchin;
          file = "/Catppuccin-frappe.tmTheme";
        };
      };

      extraPackages = with pkgs.bat-extras; [
        batman
        batpipe
      ];
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;

      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    lazygit = {
      enable = true;
    };

    zsh = {
      enable = true;

      shellAliases = {
        ll = "ls -ahlF";
        ".." = "cd ..";
        v = "nvim";
        c = "clear";
        ":q" = "exit";
        gpull = "git pull --rebase";
        gpush = "git push";
        gcom = "git commit";
        gamend = "git commit --amend";
        glog = "git log --pretty=format:\"%C(yellow)%h %C(green)%cs %Cred%d %Creset%s%Cblue [%cn]\" --decorate";
        gstat = "git status";
      };

      autosuggestion = {
        enable = true;
      };

      history = {
        size = 100;
      };

      plugins = [
        {
          name = "zsh-vi-mode";
          src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
        }
      ];

      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        ZVM_VI_HIGHLIGHT_FOREGROUND = "black";
        ZVM_VI_HIGHLIGHT_BACKGROUND = "yellow";
        ZVM_LINE_INIT_MODE = "i";
      };
    };

    atuin = {
      enable = true;
      settings = {
        enter_accept = false;
        keymap_mode = "vim-normal";
        inline_height = 20;
      };

      enableZshIntegration = true;
    };

    # Blazingly fast terminal file manager
    yazi = {
      enable = true;
      settings = {
        manager = {
          show_hidden = true;
        };
        opener.open = [
          {
            run = ''xdg-open "$1"'';
            desc = "Open";
            orphan = true;
          }
        ];
      };
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
