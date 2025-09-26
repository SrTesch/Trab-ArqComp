# Arkanoid em Assembly

Este projeto é uma implementação simples do jogo **Arkanoid** em Assembly, utilizando o **p3as** (assembler) e o **p3sim** (simulador).  
O guia abaixo explica como configurar o ambiente e rodar o programa no **Linux**.

---

## ⚙️ Pré-requisitos

Você precisa ter o **Java** instalado, pois o simulador (`p3sim.jar`) é executado com ele.

### Instalação do Java

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install default-jre -y
```

#### Arch Linux e derivados (Manjaro)
```bash
sudo pacman -Syu jre-openjdk
```

Verifique a instalação com:
```bash
java -version
```

---

## 🚀 Como rodar o projeto

1. Clone este repositório:
   ```bash
   git clone https://github.com/SrTesch/Trab-ArqComp.git
   ```

2. Entre na pasta do projeto:
   ```bash
   cd seu-repo
   ```

3. Dê permissão de execução para o assembler (somente uma vez):
   ```bash
   chmod +x p3as-linux
   ```

4. Compile e execute o jogo:
   ```bash
   ./p3as-linux arkanoid.as && java -jar p3sim.jar arkanoid.exe
   ```

---

## 🕹️ Controles
- (adicione aqui os controles do jogo, se já tiver definido)
1. Definições-> Define IVAD
2. INT0 -> a(movimentação da nav para a esquerda)
3. INT1 -> d(movimentação da nav para a direita)

## Iniciar o jogo em si:
1. CTRL + R
2. CTRL + T
Depois só curtir seu joguinho de assembly :)

---

## 📄 Licença
Este projeto é distribuído sob a licença que você preferir (MIT, GPL, etc.).