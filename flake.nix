{
  description = ''A self-seeding cache utility -
  that writes the system string locally
  To be referenced as a flake input, and set system automatically in all other flakes'';

  outputs = { self }: 
    let
      # Establish standard architectures to map our launcher script
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      
      forAllSystems = f: builtins.listToAttrs (map (system: {
        name = system;
        value = f system;
      }) supportedSystems);
    in
    {
      apps = forAllSystems (system: {
        seedCache = {
          type = "app";
          # Generate an executable package block that copies the host string
          program = "${self.packages.${system}.installer}/bin/seed-cache";
        };
      });

      packages = forAllSystems (system: {
        installer = builtins.derivation {
          name = "cache-installer";
          inherit system;
          builder = "/bin/bash";
          args = [ "-c" ''
            mkdir -p $out/bin
            cat << 'EOF' > $out/bin/seed-cache
            #!/bin/bash
            CACHE_DIR="$HOME/.config/nix/system-cache"
            mkdir -p "$CACHE_DIR"

            echo "Detecting host architecture..."
            # Query the live impure architecture string from the system context
            SYS_STR=$(nix eval --impure --raw --expr "builtins.currentSystem")

            echo "Writing immutable local system flake..."
            cat << FLAKE > "$CACHE_DIR/flake.nix"
            {
              outputs = { self }: {
                current = "${SYS_STR}";
              };
            }
            FLAKE

            echo "Success! Cache populated at $CACHE_DIR/flake.nix with value: '$SYS_STR'"
            EOF
            chmod +x $out/bin/seed-cache
          '' ];
        };
      });
    };
}
