# lib.nix

### Function to run/use - if system is preDefined
{
  # Pure function: string(from system arg) -> { arch: string, platform: string }
  splitSystem = system:
    let
      rawParts = builtins.split "([a-zA-Z0-9_]+)-([a-zA-Z0-9_]+)" system;
      matches = builtins.elemAt rawParts 1;
    in {
      arch = builtins.elemAt matches 0;
      platform = builtins.elemAt matches 1;
    };
}
