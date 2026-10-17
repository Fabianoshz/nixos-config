{ config, lib, ... }:
{
  home.file = {
    ".cursor/mcp.json".source = ./cursor.json;
  };
}
