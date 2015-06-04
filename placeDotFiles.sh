#!/bin/bash
#
# Installs all dotfiles
#
# Based on Holman does dotfiles (https://github.com/holman/dotfiles/blob/master/script/bootstrap)

DOTFILES_ROOT=$(pwd)


info () {
  printf "  [ \033[00;34m..\033[0m ] $1"
}

prompt () {
  printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

success () {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}


link_file() {
  local src=$1 dst=$2
  local overwrite= backup= skip= action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]; then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]; then

      local currentSrc=`readlink "$dst"`

      if [ "$currentSrc" == "$src" ]; then
        skip=true;
      else
        prompt "File already exists: $(basename "$dst"). [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac
      fi
    fi
  fi

  overwrite=${overwrite:-$overwrite_all}
  backup=${backup:-$backup_all}
  skip=${skip:-$skip_all}

  if [ "$overwrite" == "true" ]; then
    rm -rf "$dst"
    success "Removed $dst"
  fi

  if [ "$backup" == "true" ]; then
    mv "$dst" "${dst}.bak"
    success "Moved $dst to ${dst}.bak"
  fi

  if [ "$skip" == "true" ]; then
    success "Skipped $src"
  fi

  # Actually create the symlink if required
  if [ "$skip" != "true" ]; then
    ln -s "$1" "$2"
    success "Linked $1 to $2"
  fi
}


install_dotfiles() {
  info 'Installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false

  for src in $(find "$DOTFILES_ROOT" -maxdepth 2 -name '*.symlink'); do
    dst="$HOME/.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done
}

install_dotfiles