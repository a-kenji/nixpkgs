{
  lib,
  buildPythonPackage,
  chromadb,
  fetchPypi,
  llama-index-core,
  pythonOlder,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "llama-index-vector-stores-chroma";
  version = "0.1.10";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    pname = "llama_index_vector_stores_chroma";
    inherit version;
    hash = "sha256-l5cfezZGHvN74CO5zrVTE5bMSDYNC9vaUczhKQMBzEc=";
  };

  build-system = [ poetry-core ];

  dependencies = [
    chromadb
    llama-index-core
  ];

  pythonImportsCheck = [ "llama_index.vector_stores.chroma" ];

  meta = with lib; {
    description = "LlamaIndex Vector Store Integration for Chroma";
    homepage = "https://github.com/run-llama/llama_index/tree/main/llama-index-integrations/vector_stores/llama-index-vector-stores-chroma";
    license = licenses.mit;
    maintainers = with maintainers; [ fab ];
  };
}
