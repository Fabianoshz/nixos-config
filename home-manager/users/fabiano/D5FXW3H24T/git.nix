{
  programs.git = {
    enable = true;
    userName = "Fabiano Honorato";
    userEmail = "fhonorato@brex.com";
    extraConfig = {
      user = {
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAJllpvITzoiR8QZD5PU3COola1GbLpkYEyjsp/a6Qd8";
      };
      push = {
        autoSetupRemote = true;
      };
      gpg = {
        format = "ssh";
        "ssh" = {
	  program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
	};
      };
      core = {
        fsmonitor = true;
	untrackedCache = true;
      };
      url = {
        "git@github.com:" = {
	  insteadOf = "https://github.com/";
	};
      };
      commit = {
        gpgSign = true;
      };
      filter = {
        "lfs" = {
          process = "git-lfs filter-process";
          required = true;
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
	};
      };
    };
  };
}
