#!/bin/bash

# Lista de modelos e diretórios de destino
models=(
  "https://civitai.com/api/download/models/702110 /workspace/ComfyUI/models/checkpoint/pony"
  "https://civitai.com/api/download/models/984905 /workspace/ComfyUI/models/checkpoint/pony"
  "https://civitai.com/api/download/models/973878 /workspace/ComfyUI/models/checkpoint/pony"
  "https://civitai.com/api/download/models/571147 /workspace/ComfyUI/models/checkpoint/pony"
  "https://civitai.com/api/download/models/953264 /workspace/ComfyUI/models/checkpoint/pony"
  "https://civitai.com/api/download/models/639631 /workspace/ComfyUI/models/checkpoint/pony"
  "https://civitai.com/api/download/models/702110 /workspace/ComfyUI/models/checkpoint/pony"
  "https://civitai.com/api/download/models/1028683 /workspace/ComfyUI/models/checkpoint/pony"
  "https://civitai.com/api/download/models/914390 /workspace/ComfyUI/models/checkpoint/pony"
  "https://civitai.com/api/download/models/997833 /workspace/ComfyUI/models/checkpoint/pony"
  "https://civitai.com/api/download/models/832353 /workspace/ComfyUI/models/checkpoint/pony"
  "https://civitai.com/api/download/models/720342 /workspace/ComfyUI/models/checkpoint/pony"
  "https://civitai.com/api/download/models/978179 /workspace/ComfyUI/models/checkpoint/pony"
  "https://civitai.com/api/download/models/1025870 /workspace/ComfyUI/models/checkpoint/pony"

)

# Função para fazer o download usando download-model
download_model() {
  local url=$1
  local destination=$2

  echo "Iniciando download: $url -> $destination"
  download-model "$url" "$destination"

  # Verifica se o download foi bem-sucedido
  if [ $? -eq 0 ]; then
    echo "Download concluído: $url"
  else
    echo "Erro ao baixar: $url"
  fi
}

# Loop para processar todos os modelos
for model in "${models[@]}"; do
  # Divide a linha em URL e DESTINO
  url=$(echo $model | awk '{print $1}')
  destination=$(echo $model | awk '{print $2}')
  
  # Faz o download
  download_model "$url" "$destination"
done

echo "Todos os downloads foram concluídos."
