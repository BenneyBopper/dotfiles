#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE}")"

echo Updating dotfiles directory...
#git pull origin master

function git-update() {
	# Either clones a directory if it doesn't exist at the given location
	# or pulls it if it does exist.
	# $1 = repo URL
	# $2 = directory
	pushd . > /dev/null

	echo git-update $1 $2...
	if cd $2; then
		git pull
	else
		git clone $1 $2;
	fi
	popd > /dev/null
}

function doIt() {
	rsync --exclude ".git/" --exclude ".DS_Store" --exclude "bootstrap.sh" \
		--exclude "README.md" --exclude "os-specific/" -av --no-perms . ~

	git config --global core.excludesfile ~/.gitignore_global

	git-update https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
	git-update https://github.com/gmarik/Vundle.vim.git                 ~/.vim/bundle/Vundle.vim

	# OS specific stuff.
	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		cat ./os-specific/linux.zshrc >> ~/.zshrc
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		cat ./os-specific/mac.zshrc >> ~/.zshrc
	else
		cat ./os-specific/generic.zshrc >> ~/.zshrc
	fi
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt
else
	read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt
	fi
fi
unset doIt
