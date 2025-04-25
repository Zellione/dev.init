#!/usr/bin/env bash

set -e

NEOVIM_FOLDER="$HOME/neovim"
NEOVIM_DOWNLOAD="https://github.com/neovim/neovim/releases/download/v0.10.4/nvim-macos-arm64.tar.gz"
NEOVIM_ARCHIVE=$(echo ${NEOVIM_DOWNLOAD##*/})

# # checkout neovim
# if [ ! -d "$HOME/neovim" ]; then
#     git clone https://github.com/neovim/neovim.git "$HOME/neovim"
# fi
#
# # change branch to version 0.10
# pushd "$HOME/neovim" || exit
# git fetch
# git checkout release-0.10
# popd || exit
#
# # make neovim
# pushd "$HOME/neovim" || exit
# make clean
# make CMAKE_BUILD_TYPE=Release -j 20
# popd || exit

if [ -d "$NEOVIM_FOLDER" ]; then
    rm -rf "$NEOVIM_FOLDER"
    mkdir "$NEOVIM_FOLDER"
fi

pushd "$NEOVIM_FOLDER"
wget "$NEOVIM_DOWNLOAD"
xattr -c ./nvim-macos-arm64.tar.gz
tar xzvf nvim-macos-arm64.tar.gz
popd

