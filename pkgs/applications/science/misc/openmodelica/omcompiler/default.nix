{
  stdenv,
  lib,
  boost,
  gfortran,
  flex,
  bison,
  jre8,
  blas,
  lapack,
  cmake,
  curl,
  readline,
  expat,
  pkg-config,
  buildPackages,
  targetPackages,
  libffi,
  binutils,
  mkOpenModelicaDerivation,
  libossp_uuid,
  qt6Packages,
  openscenegraph,
  cproto,
  llvmPackages,
  colpack,
}:
let
  isCross = stdenv.buildPlatform != stdenv.hostPlatform;
  nativeOMCompiler = buildPackages.openmodelica.omcompiler;
in
mkOpenModelicaDerivation (
  {
    pname = "omcompiler";
    omtarget = "omc";
    omdir = "OMCompiler";
    omdeps = [ ];
    omautoconf = true;

    nativeBuildInputs = [
      qt6Packages.qtbase
      qt6Packages.qtsvg
      qt6Packages.qtwebengine
      qt6Packages.qttools
      boost
      cproto
      colpack
      llvmPackages.openmp
      jre8
      gfortran
      lapack
      flex
      bison
      libossp_uuid
      pkg-config
      openscenegraph
    ]
    ++ lib.optional isCross nativeOMCompiler;

    buildInputs = [
      targetPackages.stdenv.cc.cc
      blas
      lapack
      curl
      readline
      expat
      colpack
      libffi
      binutils
    ];

    # patches = [ ./ioapi0001.patch ./miniunz0002.patch];
    # patchFlags = ["-p1" "-d" "OMCompiler/3rdParty" ];

    postPatch = ''
      sed -i -e '/^\s*AR=ar$/ s/ar/${stdenv.cc.targetPrefix}ar/
                 /^\s*ar / s/ar /${stdenv.cc.targetPrefix}ar /
                 /^\s*ranlib/ s/ranlib /${stdenv.cc.targetPrefix}ranlib /' \
          $(find ./OMCompiler -name 'Makefile*')
      sed -i "s|LIBRARY DESTINATION ''\${CMAKE_INSTALL_LIBDIR}|LIBRARY DESTINATION lib2|g" ./OMCompiler/3rdParty/libzmq/CMakeLists.txt
      sed -i "s/# set(CMAKE_C_STANDARD 90)/  set(CMAKE_C_STANDARD 17)/" ./CMakeLists.txt
      sed -i "5,6d" ./OMCompiler/Parser/*.g
      sed -i "37c\
      CXXFLAGS += ''\$\(CPPFLAGS\) ''\$\(INCLUDE_NONFMI\) -I." ./OMCompiler/SimulationRuntime/c/Makefile.common
      sed -i -e 's/{"codegen_xml",\(.*\), ""/{"codegen_xml", "backend",\1/p' ./OMCompiler/Compiler/.cmake/mm_check_interface.in.mos ./OMCompiler/Compiler/boot/CompileFile.mos
    '';

    env.CFLAGS = toString [
      "-Wno-error=dynamic-exception-spec"
      "-Wno-error=implicit-function-declaration"
      "-std=gnu17"
    ];
    env.CXXFLAGS = toString [
      "-Wno-error=dynamic-exception-spec"
      "-Wno-error=implicit-function-declaration"
      "-std=c++17"
    ];

    preFixup = ''
      for entry in $(find $out -name libipopt.so); do
        patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" "$entry"
        patchelf --set-rpath '$ORIGIN':"$(patchelf --print-rpath $entry)" "$entry"
      done
    '';

    dontWrapQtApps = true;

    meta = {
      description = "Modelica compiler from OpenModelica suite";
      homepage = "https://openmodelica.org";
      license = lib.licenses.gpl3Only;
      maintainers = [
      ];
      platforms = lib.platforms.linux;
    };
  }
  // lib.optionalAttrs isCross {
    configureFlags = [ "--with-omc=${nativeOMCompiler}/bin/omc" ];
  }
)
