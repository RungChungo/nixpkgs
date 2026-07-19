{
  lib,
  qtbase,
  qttools,
  qmake,
  qt5compat,
  wrapQtAppsHook,
  openmodelica,
  mkOpenModelicaDerivation,
}:

mkOpenModelicaDerivation rec {
  pname = "omplot";
  omdir = "OMPlot";
  omdeps = [ openmodelica.omcompiler ];
  omautoconf = true;

  nativeBuildInputs = [
    qtbase
    qttools
    qmake
    qt5compat
    wrapQtAppsHook
  ];

  postPatch = with openmodelica;''
    sed -i OMPlot/Makefile.in -e 's|bindir = @includedir@|includedir = @includedir@|'
    sed -i OMPlot/OMPlot/OMPlotGUI/*.pro -e '/INCLUDEPATH +=/s|$| ../../qwt/src ../../omc/c|'
    sed -i ''$(find -name qmake.m4) -e '/^\s*LRELEASE=/ s|LRELEASE=.*$|LRELEASE=${lib.getDev qttools}/bin/lrelease|'
  sed -i OMPlot/OMPlot/OMPlotGUI/*.pro -e '
      s|\$\$\[QT_INSTALL_BINS\]/lrelease|${lib.getDev qttools}/bin/lrelease|
      /^\s*OMCLIBS =/ s|\$\$(OMBUILDDIR)|${omcompiler}|
      /^\s*OMCINC =/ s|\$\$(OMBUILDDIR)|${omcompiler}|
    '
    sed -i OMPlot/OMPlot/OMPlotGUI/OMPlotGUI.config.in -e '
      s|-lOpenModelicaRuntimeC|@RPATH_QMAKE@ -L${omcompiler}/lib/@host_short@/omc -lOpenModelicaRuntimeC|g
    '
  '';
  dontUseQmakeConfigure = true;
  QMAKESPEC = "linux-clang";

  meta = {
    description = "Plotting tool for OpenModelica-generated results files";
    homepage = "https://openmodelica.org";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [
      balodja
      smironov
    ];
    platforms = lib.platforms.linux;
  };
}
