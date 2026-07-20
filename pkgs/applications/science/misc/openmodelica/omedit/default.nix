{
  lib,
  jre8,
  qmake,
  qtbase,
  qttools,
  binutils,
  wrapQtAppsHook,
  openmodelica,
  openscenegraph,
  qt5compat,
  qtwebengine,
  qthttpserver,
  mkOpenModelicaDerivation,
}:
with openmodelica;
mkOpenModelicaDerivation {
  pname = "omedit";
  omdir = "OMEdit";
  omdeps = [
    omcompiler
    omplot
    omparser
    omsimulator
  ];
  omautoconf = true;

  nativeBuildInputs = [
    jre8
    qmake
    qtbase
    qttools
    qt5compat
    qtwebengine
    qthttpserver
    wrapQtAppsHook
  ];

  buildInputs = [
    openscenegraph
    binutils
  ];

  postPatch = ''
    sed -i ''$(find -name qmake.m4) -e '/^\s*LRELEASE=/ s|LRELEASE=.*$|LRELEASE=${lib.getDev qttools}/bin/lrelease|'
    sed -i "5,6d" ./OMEdit/OMEditLIB/Debugger/Parser/*.g
    sed -i 's|\$\$OPENMODELICAHOME/../OMParser/3|${omedit.src}/OMParser/3|g' ./OMEdit/OMEditLIB/OMEditLIB.pro
    sed -i 's|\$\$OPENMODELICAHOME/../OMParser|\$\$OPENMODELICAHOME/bin|g' ./OMEdit/OMEditLIB/OMEditLIB.pro
    sed -i 's|\$\$OPENMODELICAHOME/../|\$\$OPENMODELICAHOME/|g' ./OMEdit/OMEditLIB/OMEditLIB.pro
  '';



  dontUseQmakeConfigure = true;
  QMAKESPEC = "linux-clang";

  meta = {
    description = "Modelica connection editor for OpenModelica";
    homepage = "https://openmodelica.org";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      balodja
      smironov
    ];
    platforms = lib.platforms.linux;
  };
}
