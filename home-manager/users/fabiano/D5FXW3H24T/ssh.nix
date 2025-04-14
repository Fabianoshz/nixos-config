{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        identityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
      };
    };
  };
}
