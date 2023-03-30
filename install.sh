#!/bin/bash

dshell=$(
  whiptail --title "Default shell" --radiolist "Choose the default shell" 20 80 3 \
    "bash" "Default" ON \
    "zsh/ohmyzsh" "https://github.com/ohmyzsh/ohmyzsh" OFF \
    "fish/oh-my-fish" "https://github.com/oh-my-fish/oh-my-fish" OFF \
    3>&1 1>&2 2>&3
)

utools=$(
  whiptail --title "Utility tools" --checklist "Choose which utility tools to install" 40 160 6 \
    "bat" "A cat clone with syntax highlighting and Git integration. (https://github.com/sharkdp/bat)" ON \
    "bashtop" "Resource monitor that shows usage and stats for processor, memory, disks, network and processes. (https://github.com/aristocratos/bashtop)" ON \
    "tldr" "Collaborative cheatsheets for console commands. (https://github.com/tldr-pages/tldr)" ON \
    "exa" "a modern replacement for ls. (https://github.com/ogham/exa)" ON \
    "ncdu" "(NCurses Disk Usage) is a curses-based version of the well-known 'du'. (https://github.com/rofl0r/ncdu)" ON \
    "duf" "Disk Usage/Free Utility - a better 'df' alternative. (https://github.com/muesli/duf)" ON \
    3>&1 1>&2 2>&3
)

prog_languages=$(
  whiptail --title "Programming languages" --checklist "Choose which programming languages to install" 40 80 5 \
    "java" "" ON \
    "kotlin" "" ON \
    "dart" "" ON \
    "javascript" "" ON \
    "golang" "" ON \
    3>&1 1>&2 2>&3
)

## update the system
sudo apt update && sudo apt upgrade -y

## check if git is installed
GIT=$(which git)

if [ -z "$GIT" ]; then
  sudo apt install git
fi

# ## install and setup the default shell
case $dshell in
zsh/ohmyzsh)
  if [ ! -d $HOME/.oh-my-zsh ]; then
    sudo apt install -y zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
  sudo chsh -s /usr/bin/zsh
  ;;
fish/oh-my-fish)
  if [ ! -d $HOME/.local/share/omf ]; then
    sudo apt install -y fish
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
  fi
  sudo chsh -s /usr/bin/fish
  ;;
esac

# ## install the utility tools
if [ ! -z "$utools" ]; then
  for ut in $utools; do
    tool=$(sed -e 's/^"//' -e 's/"$//' <<<"$ut")
    echo "Installing $tool..."
    sudo apt install -y $tool
  done
fi

# ## Install asdf (https://github.com/asdf-vm/asdf)
if [ ! -d $HOME/.asdf ]; then
  echo "installing asdf"
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.11.3
fi

case $dshell in
bash)
  echo ". \"$HOME/.asdf/asdf.sh\"" >>$HOME/.bashrc
  echo ". \"$HOME/.asdf/completions/asdf.bash\"" >>$HOME/.bashrc
  ;;
zsh/ohmyzsh)
  echo ". \"$HOME/.asdf/asdf.sh\"" >>$HOME/.zshrc
  ;;
fish/oh-my-fish)
  echo "source $HOME/.asdf/asdf.fish"
  mkdir -p ~/.config/fish/completions
  and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
  ;;
esac

## Install programming languages
if [[ "$prog_languages" == *"java"* ]]; then
  asdf plugin add java https://github.com/halcyon/asdf-java.git
  asdf install java openjdk-17.0.2
  asdf global java openjdk-17.0.2
fi

if [[ "$prog_languages" == *"kotlin"* ]]; then
  asdf plugin add kotlin
  asdf install kotlin latest
  asdf global kotlin latest
fi

if [[ "$prog_languages" == *"dart"* ]]; then
  asdf plugin-add dart https://github.com/patoconnor43/asdf-dart.git
  asdf install dart latest
  asdf global dart latest
fi

if [[ "$prog_languages" == *"javascript"* ]]; then
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  asdf install nodejs lts
  asdf global nodejs lts
fi

if [[ "$prog_languages" == *"golang"* ]]; then
  sudo apt install coreutils
  asdf plugin-add golang https://github.com/kennyp/asdf-golang.git
  asdf install golang 1.20.2
  asdf global golang 1.20.2
fi

## check if snap is installed
snap_version=$(which snap)

if [ -z "$snap_version" ]; then
  sudo apt install snapd
fi

sudo snap refresh

dev_tools=$(
  whiptail --title "Developer Tools and IDE's" --checklist "Choose which to install" 40 80 16 \
    "intellij-idea-community" "" ON \
    "vscode" "" ON \
    "eclipse" "" ON \
    "netbeans" "" ON \
    "pycharm-community" "" ON \
    "goland" "" ON \
    "android-studio" "" ON \
    "atom" "" ON \
    "sublime-text" "" ON \
    "postman" "" ON \
    "insomnia" "" ON \
    "dbeaver-ce" "" ON \
    "beekeeper-studio" "" ON \
    "gradle" "" ON \
    "maven" "" ON \
    "docker" "" ON \
    3>&1 1>&2 2>&3
)

# install dev tools
if [[ "$dev_tools" = *"intellij-idea-community"* ]]; then
  echo "installing intellij-idea-community..."
  sudo snap install intellij-idea-community --classic
fi

if [[ "$dev_tools" = *"code"* ]]; then
  echo "installing vscode..."
  sudo snap install code --classic
fi

if [[ "$dev_tools" = *"eclipse"* ]]; then
  echo "installing eclipse..."
  sudo snap install eclipse --classic
fi

if [[ "$dev_tools" = *"netbeans"* ]]; then
  echo "installing netbeans..."
  sudo snap install netbeans --classic
fi

if [[ "$dev_tools" = *"pycharm-community"* ]]; then
  echo "installing pycharm-community..."
  sudo snap install pycharm-community --classic
fi

if [[ "$dev_tools" = *"goland"* ]]; then
  echo "installing goland..."
  sudo snap install goland --classic
fi

if [[ "$dev_tools" = *"android-studio"* ]]; then
  echo "installing android-studio..."
  sudo snap install android-studio --classic
fi

if [[ "$dev_tools" = *"atom"* ]]; then
  echo "installing atom..."
  wget -P ~/Downloads https://github.com/atom/atom/releases/download/v1.60.0/atom-amd64.deb
  sudo dpkg -i ~/Downloads/atom-amd64.deb
fi

if [[ "$dev_tools" = *"sublime-text"* ]]; then
  echo "installing sublime-text..."
  sudo snap install sublime-text --classic
fi

if [[ "$dev_tools" = *"postman"* ]]; then
  echo "installing postman..."
  sudo snap install postman
fi

if [[ "$dev_tools" = *"dbeaver-ce"* ]]; then
  echo "installing dbeaver-ce..."
  sudo snap install dbeaver-ce
fi

if [[ "$dev_tools" = *"beekeeper-studio"* ]]; then
  echo "installing beekeeper-studio..."
  sudo snap install beekeeper-studio
fi

if [[ "$dev_tools" = *"gradle"* ]]; then
  echo "installing gradle..."
  sudo snap install gradle --classic
fi

if [[ "$dev_tools" = *"maven"* ]]; then
  echo "installing maven..."
  sudo apt install maven -y
fi

if [[ "$dev_tools" = *"docker"* ]]; then
  echo "installing docker..."
  sudo apt-get remove docker docker-engine docker.io containerd runc
  sudo apt-get update
  sudo apt-get install \
    ca-certificates \
    curl \
    gnupg
  sudo mkdir -m 0755 -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  sudo groupadd docker
  sudo usermod -aG docker $USER
  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service
fi
