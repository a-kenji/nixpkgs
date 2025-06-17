{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "act3";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "dhth";
    repo = "act3";
    rev = "v${version}";
    hash = "sha256-GE9f4hm+R4G4NCqdPN6h5MTZqMVLkrdMnc20bOZGcu4=";
  };

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Glance at the last 3 runs of your GitHub Actions workflows";
    homepage = "https://github.com/dhth/act3";
    changelog = "https://github.com/dhth/act3/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "act3";
  };
}
