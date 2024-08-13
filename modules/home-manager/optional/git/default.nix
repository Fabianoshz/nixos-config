{
  programs.git = {
    enable = true;
    userName = "Fabiano Honorato";
    userEmail = "fabianoshz@gmail.com";
    extraConfig = {
      user = {
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOpM3ETAqRsx/mFs//pHp7vMcRQnWklwLkrA7hh8b9jq";
      };
      safe = {
        directory = "/etc/nixos";
      };
      gpg = {
        format = "ssh";
      };
      commit = {
        gpgSign = true;
      };
    };    
  };
}
