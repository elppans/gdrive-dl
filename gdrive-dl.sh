#!/bin/bash

# Verifica se o link foi passado
if [ -z "$1" ]; then
    echo "Uso: ./gdrive-dl.sh 'LINK_DO_GOOGLE_DRIVE'"
    exit 1
fi

URL="$1"

# Extrai o ID do arquivo
FILE_ID=$(echo "$URL" | sed -rn 's/.*(\/d\/|id=)([a-zA-Z0-9_-]+).*/\2/p')

# Extrai o resourcekey (se existir)
RES_KEY=$(echo "$URL" | sed -rn 's/.*resourcekey=([a-zA-Z0-9_-]+).*/\1/p')

# Monta o link base de download
DL_URL="https://drive.google.com/uc?export=download&id=$FILE_ID"

# Adiciona o resourcekey se ele foi encontrado
if [ ! -z "$RES_KEY" ]; then
    DL_URL="$DL_URL&resourcekey=$RES_KEY"
fi

echo "Iniciando download do ID: $FILE_ID..."

# O comando mestre que você validou
wget --save-cookies /tmp/cookies.txt \
     --keep-session-cookies \
     --no-check-certificate \
     --content-disposition \
     --trust-server-names \
     "$DL_URL"

# Limpa o arquivo temporário de cookies
rm -f /tmp/cookies.txt
