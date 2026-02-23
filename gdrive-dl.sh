#!/bin/bash

# --- CONFIGURAÇÃO E AJUDA ---
show_help() {
    echo "==============================================================="
    echo "gdrive-dl - O canivete suíço para downloads do Google Drive"
    echo "==============================================================="
    echo "USO:"
    echo "  gdrive-dl [OPÇÕES] 'URL'"
    echo ""
    echo "OPÇÕES:"
    echo "  -O NOME    Define um nome específico para o arquivo de saída."
    echo "  -h, --help Mostra esta tela de ajuda."
    echo ""
    echo "EXEMPLOS:"
    echo "  # Arquivo comum (Zip, ISO, Tar):"
    echo "  gdrive-dl 'https://drive.google.com/file/d/ID_AQUI/view'"
    echo ""
    echo "  # Planilha do Google (converte para .xlsx):"
    echo "  gdrive-dl 'https://docs.google.com/spreadsheets/d/ID_AQUI/edit'"
    echo ""
    echo "⚠️  AVISO IMPORTANTE (EXECUTÁVEIS):"
    echo "  O Google Drive possui políticas rígidas para arquivos .exe e .msi."
    echo "  Downloads diretos de executáveis costumam falhar ou baixar HTML."
    echo "  DICA: Sempre comprima arquivos do Windows (.zip, .7z, .rar) antes"
    echo "  de fazer o upload para garantir que o download via terminal funcione."
    echo "==============================================================="
    exit 0
}

# Verificação inicial
if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

# Tratamento de argumentos
CUSTOM_NAME=""
while getopts "O:" opt; do
  case $opt in
    O) CUSTOM_NAME="$OPTARG" ;;
    *) show_help ;;
  esac
done
shift $((OPTIND-1))

URL="$1"

# 1. EXTRAÇÃO LIMPA DO ID E RESOURCE KEY
FILE_ID=$(echo "$URL" | sed -rn 's/.*(\/d\/|id=)([a-zA-Z0-9_-]{25,}).*/\2/p')
RES_KEY=$(echo "$URL" | sed -rn 's/.*resourcekey=([a-zA-Z0-9_-]+).*/\1/p')

WGET_OPTS="--save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate --content-disposition --trust-server-names"

# 2. DETECÇÃO DE TIPO E CONSTRUÇÃO DE URL
if [[ "$URL" == *"spreadsheets"* ]]; then
    TYPE="GOOGLE SHEET"
    DL_URL="https://docs.google.com/spreadsheets/d/$FILE_ID/export?format=xlsx"
elif [[ "$URL" == *"document"* ]]; then
    TYPE="GOOGLE DOC"
    DL_URL="https://docs.google.com/document/d/$FILE_ID/export?format=docx"
else
    TYPE="DRIVE FILE"
    BASE_URL="https://drive.google.com/uc?export=download&id=$FILE_ID"
    [ ! -z "$RES_KEY" ] && BASE_URL="$BASE_URL&resourcekey=$RES_KEY"
    
    # Bypass para arquivos que disparam aviso de vírus
    echo "🔍 Verificando bypass de segurança para o ID: $FILE_ID"
    CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies "$BASE_URL" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')
    
    if [ ! -z "$CONFIRM" ]; then
        DL_URL="https://drive.google.com/uc?export=download&confirm=$CONFIRM&id=$FILE_ID"
    else
        DL_URL="$BASE_URL"
    fi
fi

# Garante que a Resource Key seja incluída se existir
[[ ! -z "$RES_KEY" ]] && [[ "$DL_URL" != *"resourcekey"* ]] && DL_URL="$DL_URL&resourcekey=$RES_KEY"

# 3. EXECUÇÃO DO DOWNLOAD
echo "Iniciando download ($TYPE)..."
if [ ! -z "$CUSTOM_NAME" ]; then
    wget $WGET_OPTS -O "$CUSTOM_NAME" "$DL_URL"
else
    wget $WGET_OPTS "$DL_URL"
fi

# Limpeza
rm -f /tmp/cookies.txt
echo "Processo concluído."
