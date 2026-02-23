#!/bin/bash

# --- CONFIGURAÇÃO E AJUDA ---
show_help() {
    echo "gdrive-dl - O canivete suíço para downloads do Google Drive/Docs"
    echo ""
    echo "USO:"
    echo "  gdrive-dl [OPÇÕES] 'URL'"
    echo ""
    echo "OPÇÕES:"
    echo "  -O NOME    Define um nome específico para o arquivo (ex: -O planilha.xlsx)"
    echo "  -h, --help Mostra esta tela de ajuda"
    echo ""
    echo "EXEMPLOS:"
    echo "  # Baixar arquivo comum do Drive (Zip, ISO, etc):"
    echo "  gdrive-dl 'https://drive.google.com/file/d/ID_AQUI/view'"
    echo ""
    echo "  # Baixar Planilha (converte para .xlsx automaticamente):"
    echo "  gdrive-dl 'https://docs.google.com/spreadsheets/d/ID_AQUI/edit'"
    echo ""
    echo "  # Baixar com nome personalizado:"
    echo "  gdrive-dl -O 'meu_backup.zip' 'https://drive.google.com/file/d/ID_AQUI/view'"
    exit 0
}

# Se não houver argumentos ou for pedido help
if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

# --- TRATAMENTO DE ARGUMENTOS ---
CUSTOM_NAME=""
while getopts "O:" opt; do
  case $opt in
    O) CUSTOM_NAME="$OPTARG" ;;
    *) show_help ;;
  esac
done
shift $((OPTIND-1))

URL="$1"

# --- DETECÇÃO DE TIPO E EXTRAÇÃO DE ID ---
# Extrai o ID (funciona para /d/ID ou id=ID)
FILE_ID=$(echo "$URL" | sed -rn 's/.*(\/d\/|id=)([a-zA-Z0-9_-]+).*/\2/p')
RES_KEY=$(echo "$URL" | sed -rn 's/.*resourcekey=([a-zA-Z0-9_-]+).*/\1/p')

# Identifica se é Spreadsheet, Doc ou arquivo comum
if [[ "$URL" == *"spreadsheets"* ]]; then
    TYPE="SHEET"
    DL_URL="https://docs.google.com/spreadsheets/d/$FILE_ID/export?format=xlsx"
elif [[ "$URL" == *"document"* ]]; then
    TYPE="DOC"
    DL_URL="https://docs.google.com/document/d/$FILE_ID/export?format=docx"
else
    TYPE="DRIVE"
    DL_URL="https://drive.google.com/uc?export=download&id=$FILE_ID"
fi

# Adiciona resourcekey se houver
if [ ! -z "$RES_KEY" ]; then
    DL_URL="$DL_URL&resourcekey=$RES_KEY"
fi

# --- EXECUÇÃO DO DOWNLOAD ---
echo "--- Iniciando Download ($TYPE) ---"

# Monta o comando básico
WGET_OPTS="--save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate --content-disposition --trust-server-names"

if [ ! -z "$CUSTOM_NAME" ]; then
    # Se o usuário definiu -O, usamos o nome dele
    wget $WGET_OPTS -O "$CUSTOM_NAME" "$DL_URL"
else
    # Se não, o --content-disposition cuida de pegar o nome real (ex: TESTE.xlsx)
    wget $WGET_OPTS "$DL_URL"
fi

# Limpeza
rm -f /tmp/cookies.txt
echo "--- Finalizado ---"
