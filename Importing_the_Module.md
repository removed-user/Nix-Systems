# Importing the Module in a flake

```nix
{
  description = "A project flake consuming our installed profile flakeModule";

  inputs = {
    # 1. Pull down a minimal module engine or framework like flake-parts
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, flake-parts }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      
      # 2. Import the module file directly out of your local user profile path
      imports = [
        /nix/var/nix/profiles/per-user/YOUR_USERNAME/profile/module.nix
      ];

      # 3. Consuming the module configuration data
      perSystem = { config, ... }: {
        # config.mysystem.system now returns your cached host architecture cleanly!
        packages.default = builtins.derivation {
          name = "my-pure-package";
          system = config.mysystem.system; 
          builder = "/bin/bash";
          args = [ "-c" "echo 'Built via profile flakeModule system string!' > \$out" ];
        };
      };
    };
}
```
