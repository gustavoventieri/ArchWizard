# ArchWizard - Instalador Automático do Arch Linux

## 📜 Sobre

**ArchWizard** é um script interativo para instalação automatizada do Arch Linux. Ele permite escolher o disco, definir nomes e configurar a instalação de forma simples e rápida.

## 🚀 Funcionalidades

- **Seleção interativa do disco** 🔍
- **Particionamento automático** 🛠️
- **Instalação do sistema base** 📦
- **Configuração de rede e hostname** 🌐
- **Criação de usuário final** 👤
- **Instalação e configuração do GRUB** ⚙️
- **Suporte para EFI e BIOS** 💾

## 📥 Download e Execução

1. **Inicie o Arch Linux pelo pendrive**
2. **Conecte-se à internet** (`iwctl` para Wi-Fi ou cabo automático)
3. **Baixe o script**:
   ```bash
   curl -O https://github.com/gustavoventieri/ArchWizard
   ```
4. **Dê permissão de execução**:
   ```bash
   chmod +x archwizard.sh
   ```
5. **Execute o script**:
   ```bash
   bash ./archwizard.sh
   ```

## 🔧 Configuração Manual

Caso queira modificar o script antes da execução, edite o arquivo `archwizard.sh`:

```bash
nano archwizard.sh
```

## 🛠️ Requisitos

- Computador com suporte a **UEFI ou BIOS Legacy**
- Conexão com a internet
- Disco disponível para instalação

## 📌 Observações

- **Todos os dados do disco selecionado serão apagados!**
- Após a instalação, o sistema será reiniciado automaticamente.

## 📜 Licença

Este projeto está licenciado sob a **MIT License**. Você pode modificar e compartilhar livremente.

---

Criado por [Gustavo Ventieri](https://github.com/gustavoventieri) e [Nickolas Maia](https://github.com/nickolss) 🚀

