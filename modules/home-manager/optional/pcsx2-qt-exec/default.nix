{ ... }:
{ 
  home.file = {
    ".local/bin/pcsx2-qt-exec.sh" = {
      source = ./pcsx2-qt-exec.sh;
      executable = true;
    };
  };
}
