{ stdenv, fetchurl, makeWrapper, sbcl, sqlite, freetds, libzip, curl, git, cacert, openssl }:
let
  pname = "pgloader";
  version = "3.6.1";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://github.com/dimitri/pgloader/archive/v${version}.tar.gz";
    sha256 = "1yh9ifwiysm0hhyppdxkhyyr4w51jwdvc0hcf3vwb54wiqp4zabg";
  };

  deps = stdenv.mkDerivation {
    name = "${name}-deps";
    inherit src;
    buildInputs = [ sbcl cacert sqlite freetds libzip curl git openssl ];

    LD_LIBRARY_PATH = stdenv.lib.makeLibraryPath [ sqlite libzip curl git openssl freetds ];

    buildPhase = ''
      export PATH=$PATH:$out/bin
      export HOME=$TMPDIR

      make libs
      make buildapp
    '';

    installPhase = ''
      cp -a . $out
    '';

    dontStrip = true;
    enableParallelBuilding = false;

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "0gwjhybwnijdf4279ic1jshg2dqlidlsgpbngmlwajfg8apkij7z";
  };

in
stdenv.mkDerivation rec {

  inherit name pname deps;

  buildInputs = [ sbcl cacert sqlite freetds libzip curl git openssl makeWrapper ];

  LD_LIBRARY_PATH = stdenv.lib.makeLibraryPath [ sqlite libzip curl git openssl freetds ];

  buildPhase = ''
    export PATH=$PATH:$out/bin
    export HOME=$TMPDIR

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
