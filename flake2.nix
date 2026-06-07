{
  description = "A flake that exposes the host identity package for your profile";

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
        # This package creates the static flake artifact in the nix store
        default = builtins.derivation {
          name = "host-system-cache";
          inherit system;
          builder = "/bin/bash";
          args = [ "-c" ''
            mkdir -p $out
            cat << 'EOF' > $out/flake.nix
            {
              outputs = { self }: {
                current = "${system}";
              };
            }
            EOF
          '' ];
        };
      });
    };
}
