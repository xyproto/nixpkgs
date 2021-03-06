{ stdenv, composableDerivation, fetchurl, xapian, pkgconfig, zlib
, python ? null, php ? null, ruby ? null }:

let inherit (composableDerivation) wwf; in

composableDerivation.composableDerivation {} rec {

  name = "xapian-bindings-1.2.23";

  src = fetchurl {
    url = "http://oligarchy.co.uk/xapian/1.2.23/${name}.tar.xz";
    sha256 = "05929d9bq9df25kh2i6gk2w09w7p5qknf9cc7mrm2g46finbbd0r";
  };

  buildInputs = [ xapian pkgconfig zlib ];

  # most interpreters aren't tested yet.. (see python for example how to do it)
  flags =
         wwf {
           name = "python";
           enable = {
            buildInputs = [ python ];
            # export same env vars as in pythonNew
            preConfigure = ''
              export PYTHON_LIB=$out/lib/${python.libPrefix}/site-packages
              mkdir -p $out/nix-support
              echo "export NIX_PYTHON_SITES=\"$out:\$NIX_PYTHON_SITES\"" >> $out/nix-support/setup-hook
              echo "export PYTHONPATH=\"$PYTHON_LIB:\$PYTHONPATH\"" >> $out/nix-support/setup-hook
            '';
           };
         }
      // wwf {
           name = "php";
           enable = {
             buildInputs = [ php ];
             preConfigure = ''
               export PHP_EXTENSION_DIR=$out/lib/php # TODO use a sane directory. Its not used anywhere by now
             '';
           };
         }
      // wwf {
           name = "ruby";
           enable = {
             buildInputs = [ ruby ];
             preConfigure = ''
               export RUBY_LIB=$out/${ruby.libPath}
               export RUBY_LIB_ARCH=$RUBY_LIB
               mkdir -p $out/nix-support
               echo "export RUBYLIB=\"$RUBY_LIB:\$RUBYLIB\"" >> $out/nix-support/setup-hook
               echo "export GEM_PATH=\"$out:\$GEM_PATH\"" >> $out/nix-support/setup-hook
             '';
           };
         }

      # note: see configure --help to get see which env vars can be used
      # // wwf { name = "tcl";     enable = { buildInputs = [ tcl ];};}
      # // wwf { name = "csharp"; }
      # // wwf { name = "java"; }
      ;

  cfg = {
    pythonSupport = true;
    phpSupport = false;
    rubySupport = true;
  };

  meta = {
    description = "Bindings for the Xapian library";
    homepage = xapian.meta.homepage;
    license = stdenv.lib.licenses.gpl2Plus;
    maintainers = [ stdenv.lib.maintainers.chaoflow ];
    platforms = stdenv.lib.platforms.unix;
  };
}
