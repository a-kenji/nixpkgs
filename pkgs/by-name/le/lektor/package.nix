{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  fetchPypi,
  fetchpatch,
  nodejs,
  npmHooks,
  python3,
}:

let
  python = python3.override {
    self = python;
    packageOverrides = self: super: {
      mistune = super.mistune.overridePythonAttrs (old: rec {
        version = "2.0.5";
        src = fetchPypi {
          inherit (old) pname;
          inherit version;
          hash = "sha256-AkYRPLJJLbh1xr5Wl0p8iTMzvybNkokchfYxUc7gnTQ=";
        };
      });
    };
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "lektor";
  version = "3.4.0b12";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "lektor";
    repo = "lektor";
    tag = "v${version}";
    # fix for case-insensitive filesystems
    postFetch = ''
      rm -f $out/tests/demo-project/content/icc-profile-test/{LICENSE,license}.txt
    '';
    hash = "sha256-y0/fYuiIB/O5tsYKjzOPnCafOIZCn4Z5OITPMcnHd/M=";
  };

  patches = [
    # Fixes test_thumbnail.py with Pillow 11.0
    # see lektor/lektor #1202
    (fetchpatch {
      name = "lektor-pillow-11.patch";
      url = "https://github.com/lektor/lektor/commit/af99ea4265e05227d7452977949475196a58edfa.patch";
      hash = "sha256-PmSmX9Ku5rAzN2FzLwvXYeUqN683opLRt9J35w56cfg=";
    })
  ];

  npmDeps = fetchNpmDeps {
    src = "${src}/${npmRoot}";
    hash = "sha256-LXe5/u4nAGig8RSu6r8Qsr3p3Od8eoMxukW8Z4HkJ44=";
  };

  npmRoot = "frontend";

  nativeBuildInputs = [
    python.pkgs.hatch-vcs
    python.pkgs.hatchling
    nodejs
    npmHooks.npmConfigHook
  ];

  propagatedBuildInputs = with python.pkgs; [
    babel
    click
    flask
    inifile
    jinja2
    markupsafe
    marshmallow
    marshmallow-dataclass
    mistune
    pillow
    pip
    python-slugify
    requests
    watchfiles
    werkzeug
  ];

  nativeCheckInputs = with python.pkgs; [
    pytest-click
    pytest-mock
    pytestCheckHook
  ];

  postInstall = ''
    cp -r lektor/translations "$out/${python.sitePackages}/lektor/"
  '';

  pythonImportsCheck = [
    "lektor"
  ];

  disabledTests = [
    # Tests require network access
    "test_path_installed_plugin_is_none"
    "test_VirtualEnv_run_pip_install"
  ];

  postCheck = ''
    make test-js
  '';

  meta = {
    description = "Static content management system";
    homepage = "https://www.getlektor.com/";
    changelog = "https://github.com/lektor/lektor/blob/v${version}/CHANGES.md";
    license = lib.licenses.bsd3;
    mainProgram = "lektor";
    maintainers = [ ];
  };
}
