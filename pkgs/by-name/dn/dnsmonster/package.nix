{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  libpcap,
}:

buildGoModule rec {
  pname = "dnsmonster";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "mosajjal";
    repo = "dnsmonster";
    tag = "v${version}";
    hash = "sha256-0WHTrqnc3vYQro+nSsQipAPVymR8L4uOwtd9GJHxhVM=";
  };

  vendorHash = "sha256-QCG/rhs4Y3lLDVU15cBNUZqbKc4faNAqKMhMOFwK2SY=";

  buildInputs = [ libpcap ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/mosajjal/dnsmonster/util.releaseVersion=${version}"
  ];

  meta = {
    description = "Passive DNS Capture and Monitoring Toolkit";
    homepage = "https://github.com/mosajjal/dnsmonster";
    changelog = "https://github.com/mosajjal/dnsmonster/releases/tag/v${version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fab ];
    broken = stdenv.hostPlatform.isDarwin;
    mainProgram = "dnsmonster";
  };
}
