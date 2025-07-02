{ config, lib, ... }:
{
  home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;
}
