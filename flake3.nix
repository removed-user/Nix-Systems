{
  description = "Installs a static flakeModule containing host architecture data";

  outputs = { self }: 
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: builtins.listToAttrs (map (system: {
        name = system;
        value = f system;
      }) supportedSystems);
    in
    {
      packages = forAllSystems (system: {
        default = builtins.derivation {
          name = "mysystem-flake-module";
          inherit system;
          builder = "/bin/bash";
          args = [ "-c" ''
            mkdir -p $out
            cat << 'EOF' > $out/module.nix
            { lib, config, ... }: {
              options.mysystem.system = lib.mkOption {
                type = lib.types.str;
                default = "${system}";
                description = "The cached host system architecture.";
              };
            }
            EOF
          '' ];
        };
      });
    };
}
