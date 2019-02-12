# default.nix scripts repository expression

let scriptDer = pkg:
    with import <nixpkgs> {};
        let path      = ./. + "/${pkg.dir}";
            installer = '' mkdir -p $out/bin
                           cp ''${src} $out/bin/${pkg.dir}
                           chmod 755 $out/bin/${pkg.dir}
                        '';
        in  stdenv.mkDerivation rec
            { name         = "${pkg.dir}-${pkg.version}"
            ; version      = "1.0"
            ; src          = builtins.toPath "${path}/main.sh"
            ; phases       = "installPhase fixupPhase"
            ; installPhase = installer
            ; meta         = { license     = stdenv.lib.licenses.bsd3
                             ; maintainers = [ "mwr" ]
                             ; description = pkg.description
                             ; }
            ; };
in  { backup-configs = scriptDer ( import ./backup-configs )
    ; packup         = scriptDer ( import ./packup         )
    ; }