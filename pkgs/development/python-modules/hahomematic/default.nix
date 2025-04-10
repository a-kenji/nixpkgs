{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchFromGitHub,
  freezegun,
  orjson,
  pydevccu,
  pytest-aiohttp,
  pytest-socket,
  pytestCheckHook,
  python-slugify,
  pythonOlder,
  setuptools,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "hahomematic";
  version = "2025.4.0";
  pyproject = true;

  disabled = pythonOlder "3.13";

  src = fetchFromGitHub {
    owner = "SukramJ";
    repo = "hahomematic";
    tag = version;
    hash = "sha256-bEMGt53tXJdGIpjP8sZ1VkKH/ky+VVnIF6t+oS/YYlY=";
  };

  __darwinAllowLocalNetworking = true;

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools==78.1.0" "setuptools" \
  '';

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    orjson
    python-slugify
    voluptuous
  ];

  nativeCheckInputs = [
    freezegun
    pydevccu
    pytest-aiohttp
    pytest-socket
    pytestCheckHook
  ];

  pythonImportsCheck = [ "hahomematic" ];

  meta = with lib; {
    description = "Python module to interact with HomeMatic devices";
    homepage = "https://github.com/SukramJ/hahomematic";
    changelog = "https://github.com/SukramJ/hahomematic/blob/${src.tag}/changelog.md";
    license = licenses.mit;
    maintainers = with maintainers; [
      dotlambda
      fab
    ];
  };
}
