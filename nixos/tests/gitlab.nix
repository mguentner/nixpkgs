# This test runs gitlab and checks if it works

import ./make-test.nix ({ pkgs, ...} : {
  name = "gitlab";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ domenkozar offline ];
  };

  nodes = {
    gitlab = { config, pkgs, ... }: {
      virtualisation.memorySize = 768;
      services.gitlab.enable = true;
      services.gitlab.databasePassword = "gitlab";
      services.gitlab.secrets.secret = "itaew3lai5EeLiob8ute";
      services.gitlab.secrets.db     = "itaew3lai5EeLiob8ute";
      services.gitlab.secrets.otp    = "itaew3lai5EeLiob8ute";
      systemd.services.gitlab.serviceConfig.TimeoutStartSec = "10min";
    };
  };

  testScript = ''
    $gitlab->start();
    $gitlab->waitForUnit("gitlab.service");
    $gitlab->waitForUnit("gitlab-sidekiq.service");
    $gitlab->waitUntilSucceeds("curl http://localhost:8080/users/sign_in");
  '';
})
