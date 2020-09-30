{ stdenv, fetchFromGitHub, boost17x, catch2, fmt, libusb, libzip, lz4, nlohmann_json, pkgconfig, zstd, cmake, git, python2, perl, qtbase, SDL2 }:

stdenv.mkDerivation rec {
  zstdFix = zstd.overrideAttrs (old: {
        postFixup = ''
          sed -i -e "s@$dev/$dev@$dev@" -e "s@libdir=.*@libdir=$out/lib@" $dev/lib/pkgconfig/libzstd.pc
        '';
      }); 

  pname = "yuzu";
  version = "unstable-2020-09-30";

  src = fetchFromGitHub {
    owner = "yuzu-emu";
    repo = "yuzu-nightly";
    fetchSubmodules = true;
    deepClone = true;  # Yuzu's CMake submodule check uses .git presence.
    branchName = "master";  # For nicer in-app version numbers.
	rev = "4d0ae1a17a031488eadfa9133dac157fb71900c0";
	sha256 = "0j082ds356fdfx38ibmmlwzvpj2nm0202pmr1031w8sf0qx0d0cr";
  };

  patches = [ ./patches.diff ];

  nativeBuildInputs = [ pkgconfig cmake git perl python2 ];
  buildInputs = [ zstdFix boost17x catch2 fmt libusb libzip lz4 nlohmann_json qtbase SDL2 ];

  cmakeFlags = [
    # Disable as much vendoring as upstream allows. We still use vendored
    # libunicorn since the fork used by Yuzu is significantly different.
    "-DYUZU_USE_BUNDLED_QT=OFF"
    "-DYUZU_USE_BUNDLED_UNICORN=ON"
  ];

  meta = with stdenv.lib; {
    description = "Experimental open-source emulator for the Nintendo Switch";
    homepage = "https://yuzu-emu.org";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ delroth ];
  };
}
