{ lib, stdenv, fetchFromGitHub, kernel }:

stdenv.mkDerivation rec {
	pname = "xpad";
	version = "3.2";

	src = fetchFromGitHub {
		owner = "paroj";
		repo = "xpad";
		rev = "c379818298e0e7477b4a070e219c81817412226c";
		sha256 = "sha256-NVml2NNWPFQeHDAFvR1niiDEsW28s64OEg+FTnI4bw4=";
	};

  patches = [./flydigi-vader.patch];

	setSourceRoot = ''
		export sourceRoot=$(pwd)/source
	'';

	nativeBuildInputs = kernel.moduleBuildDependencies;

	makeFlags = kernel.makeFlags ++ [
		"-C"
		"${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
		"M=$(sourceRoot)"
	];

	buildFlags = [ "modules" ];
	installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];
	installTargets = [ "modules_install" ];

	meta = with lib; {
		description = "xpad kernel module";
		homepage = "https://github.com/paroj/xpad";
		license = licenses.gpl2Plus;
		platforms = platforms.linux;
	};
}