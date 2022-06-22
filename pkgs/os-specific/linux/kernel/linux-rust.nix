{ lib, buildPackages, fetchFromGitHub, perl, buildLinux, nixosTests, modDirVersionArg ? null, ... } @ args:

with lib;

buildLinux (args // rec {
  version = "5.19.0-rc1";
  modDirVersion = "5.19.0-rc1";
  
  # modDirVersion needs to be x.y.z, will automatically add .0 if needed
  #modDirVersion = if (modDirVersionArg == null) then concatStringsSep "." (take 3 (splitVersion "${version}.0")) else modDirVersionArg;

  # branchVersion needs to be x.y
  extraMeta.branch = versions.majorMinor version;

  src = fetchFromGitHub {
    owner = "Rust-for-Linux";
    repo = "linux";
    rev = "9f4510ea769db8ea6d974f11a45322a1cf55e6ca";
    sha256 = "jWgFRasVl5STA/AYvFUh+8cpGm4GgA+B78XKtCxx6VU=";
  };

  structuredExtraConfig = with lib.kernel; {
    DEBUG_INFO_BTF = no;
    MODVERSIONS = no;
    RETPOLINE = no;

    RUST = yes;
  };

  isRust = true;
  
} // (args.argsOverride or { }))
