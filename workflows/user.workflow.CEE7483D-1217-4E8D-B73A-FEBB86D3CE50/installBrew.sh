#!/usr/bin/env zsh

brew -v &> /dev/null || {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}
brew install --cask r
rhome="/Library/Frameworks/R.framework/Resources/bin/"
addPathString="PATH=$PATH:$rhome"
echo $addPathString > ~/.bash_profile
echo $addPathString > ~/.bashrc
echo $addPathString > ~/.zshrc
echo $addPathString > ~/.kshrc
echo $addPathString > ~/.config/fish
