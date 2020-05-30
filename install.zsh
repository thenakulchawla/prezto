#!/usr/bin/env zsh

git clone --recursive https://github.com/thenakulchawla/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    dest="${ZDOTDIR:-$HOME}/.${rcfile:t}"
    if [ -e "$dest" ]; then
        mv "$dest" "$dest.bak"
    fi
    ln -s "$rcfile" "$dest"
done
