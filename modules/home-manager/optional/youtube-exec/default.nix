{ ... }:
{ 
  home.file = {
    ".local/bin/youtube-exec.sh" = {
      source = ./youtube-exec.sh;
      executable = true;
    };
  };
}
