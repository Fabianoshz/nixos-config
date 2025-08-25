{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        identityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
      };
      "*-brex.brex.sandboxes.site" = {
        identityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
        proxyCommand = "/Users/fabiano/.crafting/sandbox/cli/current/bin/cs ssh-proxy %h:443";
        user = "owner";
        identityFile = "/Users/fabiano/.crafting/sandbox/id_client";
        extraOptions = {
          HashKnownHosts = "no";
          UserKnownHostsFile = "/Users/fabiano/.crafting/sandbox/known_hosts";
          StrictHostKeyChecking = "yes";
        };
      };
      "i-* mi-*" = {
        proxyCommand = "sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\"";
      };
    };
  };
}
