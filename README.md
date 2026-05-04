# 🐬 Flipper Zero Deploy Script

Automação simples e direta para deploy de conteúdos no Flipper Zero via shell.

> Porque copiar arquivo na mão em 2026 já deveria ser considerado crime leve.

---

## 📦 Sobre o projeto

Este script (`flipper.sh`) foi criado para simplificar o processo de envio de arquivos para o Flipper Zero, eliminando etapas repetitivas e erros humanos.

Ele abstrai operações comuns como:

- Transferência de arquivos
- Organização de diretórios
- Deploy rápido de payloads / assets

Tudo com um único comando.

O objetivo aqui não é ser “framework”, é ser **rápido e confiável**.

---

## ⚙️ Requisitos

Antes de usar:

- Flipper Zero conectado via USB
- Acesso ao sistema de arquivos (montado ou via ferramenta compatível)
- Ambiente Linux (ou WSL)

Dependendo do seu setup, você provavelmente já tem tudo isso.

---

## 🚀 Uso

Clone o repositório:

```bash
git clone https://github.com/NUMAflex/flipperzero-deploy.git
cd flipperzero-deploy
