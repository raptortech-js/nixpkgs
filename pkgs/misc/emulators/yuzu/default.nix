{ stdenv, fetchFromGitHub, boost17x, catch2, fmt, libusb, libzip, lz4, nlohmann_json, pkgconfig, zstd, cmake, git, python2, perl, qtbase, SDL2 }:

stdenv.mkDerivation rec {
  zstdFix = zstd.overrideAttrs (old: {
        postFixup = ''
          sed -i -e "s@$dev/$dev@$dev@" -e "s@libdir=.*@libdir=$out/lib@" $dev/lib/pkgconfig/libzstd.pc
        '';
      }); 

  pname = "yuzu";
  version = "unstable-2019-05-03";

  #src = /home/jackie/foss/yuzu-mainline ;
  src = fetchFromGitHub {
    owner = "yuzu-emu";
    repo = "yuzu-nightly";
    fetchSubmodules = true;
    deepClone = true;  # Yuzu's CMake submodule check uses .git presence.
    branchName = "master";  # For nicer in-app version numbers.
	rev = "53829d4cbd6cc84963191a483688d407ec6fe14d";
	#rev = "969692325baf6c4dc85d4e347ac2b979bb1c97d3";
    #rev = "1f72bb733f743d55ac890c990f0fefea9a0ef290";
	#rev = "a2eb44db825a892cc2863bd1f5d0352c273ff0f0";
	sha256 = "16k9z4kynyry3sdp538wfs3pj7i0wjrnpswwcgp52j2sdjk632dh";
    #sha256 = "0v97f0mq2qr1r210rmf9s6lai1ikrki60bjwvlx9kbjgsnmv1z01"; # DEFINITELY wrong
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
