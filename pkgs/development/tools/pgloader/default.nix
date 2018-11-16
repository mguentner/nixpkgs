{ stdenv, fetchurl, makeWrapper, sbcl, sqlite, freetds, libzip, curl, git, cacert, openssl }:
let
  pname = "pgloader";
  version = "3.5.2";
  name = "${pname}-${version}";

  src = fetchurl {
    # not possible due to sandbox
    url = "https://github.com/dimitri/pgloader/archive/v${version}.tar.gz";
    sha256 = "1bk5avknz6sj544zbi1ir9qhv4lxshly9lzy8dndkq5mnqfsj1qs";
  };

  deps = stdenv.mkDerivation {
    name = "${name}-deps";
    inherit src;
    buildInputs = [ sbcl cacert sqlite freetds libzip curl git openssl ];

    LD_LIBRARY_PATH = stdenv.lib.makeLibraryPath [ sqlite libzip curl git openssl freetds ];

    patches = [ ./extra-make-step.patch ];

    buildPhase = ''
      export PATH=$PATH:$out/bin
      export HOME=$TMPDIR

      cat Makefile

      make libs
      make fetch_buildapp
    '';

    installPhase = ''
      cp -a . $out
    '';

    dontStrip = true;
    enableParallelBuilding = false;

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "1jqv6cv0gzlmy0fxhqvl75ln49xy7pddmrapr0glz29dkzvwwwm0";
  };

in
stdenv.mkDerivation rec {

  inherit name pname deps;

  buildInputs = [ sbcl cacert sqlite freetds libzip curl git openssl makeWrapper ];

  LD_LIBRARY_PATH = stdenv.lib.makeLibraryPath [ sqlite libzip curl git openssl freetds ];

  buildPhase = ''
    export PATH=$PATH:$out/bin
    export HOME=$TMPDIR

    make buildapp
    make pgloader
  '';

  src = deps;

  dontStrip = true;
  enableParallelBuilding = false;

  installPhase = ''
    install -Dm755 build/bin/pgloader "$out/bin/pgloader"
    wrapProgram $out/bin/pgloader --prefix LD_LIBRARY_PATH : "${LD_LIBRARY_PATH}"
  '';

  meta = with stdenv.lib; {
    homepage = https://pgloader.io/;
    description = "pgloader loads data into PostgreSQL and allows you to implement Continuous Migration from your current database to PostgreSQL";
    maintainers = with maintainers; [ mguentner ];
    license = licenses.postgresql;
    platforms = platforms.all;
  };

}

