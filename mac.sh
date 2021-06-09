#!/usr/bin/env bash

script_dir=$(pwd) # store current working directory

println() {
  printf "%b\n" "$1"
}

if ! command -v brew &>/dev/null; then
  println "The missing package manager for OS X"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  if [ ! -f "$HOME/.bashrc" ]; then
    touch $HOME/.bashrc
  fi

  if ! grep -qs "recommended by brew doctor" ~/.bashrc; then
    println "Put Homebrew location earlier in PATH..."
      printf '\n# recommended by brew doctor\n' >> ~/.bashrc
      printf 'export PATH="/usr/local/bin:$PATH"\n' >> ~/.bashrc
      export PATH="/usr/local/bin:$PATH"
  fi
else
  println "Homebrew already installed. Skipping..."
fi

new_directories="$HOME/.bin $HOME/.config/nvim $HOME/.git_template/hooks"
for dir in "$new_directories"; do
  if [[ ! -d "$dir" ]]; then
    println "Creating $dir..."
    mkdir -p "$dir"
  fi
done

# Symlink dotfiles
dir=./dotfiles
home_files=".vimrc .tmux.conf .zshrc .gitconfig .gitignore .default-npm-packages"
config_files="karabiner.edn"
ctags_files="md.ctags"
nvim_files="init.vim"

if [[ -d $dir ]]; then
  cd $dir
  for file in $home_files; do
    if [[ -f $file ]]; then
      println "Creating symlink to $file in home directory."
      ln -sf $(pwd)/$file ~/$file
    fi
  done

  for file in $config_files; do
    if [[ -f $file ]]; then
      println "Creating symlink to $file in home/.config directory."
      ln -sf $(pwd)/$file ~/.config/$file
    fi
  done

  for file in $ctags_files; do
    if [[ -f $file ]]
    then
      echo "Creating symlink to $file in home/.config/ctags directory."
      ln -sf $(pwd)/$file ~/.config/ctags/$file
    fi
  done

  for file in $nvim_files; do
    if [[ -f $file ]]
    then
      echo "Creating symlink to $file in home/.config/nvim directory."
      ln -sf $(pwd)/$file ~/.config/nvim/$file
    fi
  done

  cd $script_dir
fi

# Symlink git hooks
dir=./.git_template/hooks
hooks="ctags post-commit post-merge post-checkout post-rewrite"

if [[ -d $dir ]]
then
  cd $dir
  for file in $hooks; do
    if [[ -f $file ]]
    then
      println "Creating symlink to $file in git template directory."
      ln -sf $(pwd)/$file ~/$dir/$file
    fi
  done
fi

# Brew
if [[ -z "${UPGRADE_BREW}" ]]
then
  println "Updating Homebrew formulas..."
  brew update
  brew upgrade
  brew bundle --file $script_dir/BrewFile
fi

# asdf  plugins
println "Installing asdf plugins..."
asdf plugin add nodejs
asdf install nodejs 14.16.1
asdf global nodejs 14.16.1

asdf plugin-add yarn
asdf install yarn latest
yarn config set prefix ~/.yarn # To make sure yarn packages are globally accessible

asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby 3.0.1
asdf install ruby 2.7.3
asdf global ruby 3.0.1

# zshell and oh-my-zshell
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  println "Installing oh my zshell..."
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ ! -d "/Applications/Postgres.app" ]; then
  println "Downloading Postgres..."
  cd "$HOME/Downloads"
  curl -LJO https://github.com/PostgresApp/PostgresApp/releases/download/v2.4.3/Postgres-2.4.3-9.5-9.6-10-11-12-13.dmg
  cd "$script_dir"
fi
