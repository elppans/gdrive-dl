# gdrive-dl

Um script Bash simples e eficiente para realizar downloads do Google Drive via terminal, lidando automaticamente com IDs, Resource Keys e redirecionamentos de segurança.

## 🚀 Funcionalidades

- Extrai automaticamente o `FILE_ID` de links de visualização ou compartilhamento.
- Suporte nativo para `resourcekey` (necessário para arquivos antigos/específicos).
- Gerenciamento automático de cookies para evitar bloqueios.
- Utiliza `wget` com flags otimizadas para preservar o nome original do arquivo.

## 📦 Instalação

1. Clone o repositório:
   ```bash
   git clone [https://github.com/SEU_USUARIO/gdrive-dl.git](https://github.com/SEU_USUARIO/gdrive-dl.git)
   cd gdrive-dl

```

2. Dê permissão de execução ao script:
```bash
chmod +x gdrive-dl.sh

```


3. (Opcional) Torne-o global no sistema:
```bash
sudo cp gdrive-dl.sh /usr/local/bin/gdrive-dl

```



## 🛠️ Como usar

Basta passar o link de compartilhamento do Google Drive entre aspas:

```bash
gdrive-dl "[https://drive.google.com/file/d/ID_DO_ARQUIVO/view?usp=sharing](https://drive.google.com/file/d/ID_DO_ARQUIVO/view?usp=sharing)"

```

Se o link possuir uma `resourcekey`, o script irá detectá-la automaticamente:

```bash
gdrive-dl "[https://drive.google.com/file/d/ID/view?resourcekey=CHAVE_AQUI](https://drive.google.com/file/d/ID/view?resourcekey=CHAVE_AQUI)"

```

## 🔍 Por que usar este script?

Downloads diretos via `wget` ou `curl` no Google Drive costumam falhar porque o Drive redireciona o usuário para uma página de confirmação (especialmente se o arquivo for binário ou grande). Este script automatiza o processo de:

1. Identificar o tipo de link.
2. Montar a URL de exportação correta.
3. Lidar com os cookies de sessão necessários para o "handshake" do download.

## ⚠️ Requisitos

* `bash`
* `wget`
* `sed`

---
