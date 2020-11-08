# default.nix scripts repository expression

let mkScriptDerivation = pkg:
    with import <nixpkgs> {};
        let path      = ./. + "/${pkg.dir}";
            installer = '' mkdir -p $out/bin
                           cp ''${src} $out/bin/${pkg.dir}
                           chmod 755 $out/bin/${pkg.dir}
                        '';
        in  stdenv.mkDerivation rec
            { name         = "${pkg.dir}-${pkg.version}"
            ; version      = "1.1"
            ; src          = "${path}/main.sh"
            ; phases       = "installPhase fixupPhase"
            ; installPhase = installer
            ; meta         = { license     = stdenv.lib.licenses.bsd3
                             ; maintainers = [ "Mark W. Ruszczycky" ]
                             ; description = pkg.description
                             ; }
            ; };
in  { packup       = mkScriptDerivation ( import ./packup       );
      pack-notes   = mkScriptDerivation ( import ./pack-notes   );
      unpack-notes = mkScriptDerivation ( import ./unpack-notes );
    }
