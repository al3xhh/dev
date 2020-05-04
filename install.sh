#!/bin/bash

# FUNCTIONS
###########

symbolic_links() {
    for file in $1;
    do
        ln -s $2/$3/$file
    done
}

config_symbolic_links() {
    for file in $1;
    do
        ln -s "$2/.config/$3/$file"
    done
}


FILES=".gitconfig \
       .i3status.conf \
       .vim \
       .vimrc \
       .oh-my-zsh \
       .zshrc"

DEV_FOLDER=$1

# Config files in home folder
#############################
GIT_FILES=".gitconfig"
I3_FILES=".i3status.conf"
VIM_FILES=".vim \
           .vimrc"
ZSH_FILES=".oh-my-zsh \
           .zshrc"

# Config files inside ~/.config
###############################
I3_CONFIG_FILES="i3"
TERMINATOR_CONFIG_FILES="terminator"

# HOME FOLDER
#############
cd ~

# Make a backup of each file
############################
for file in $FILES;
do
    mv $file "$file.bck"
done

# Make symbolic links to dev folder
###################################
symbolic_links "$GIT_FILES" "$DEV_FOLDER" "git"
symbolic_links "$I3_FILES" "$DEV_FOLDER" "i3"
symbolic_links "$VIM_FILES" "$DEV_FOLDER" "vim"
symbolic_links "$ZSH_FILES" "$DEV_FOLDER" "zsh"

# ~/.CONFIG FOLDER
##################
cd .config

# Make a backup of each file
############################
for file in $CONFIG_FILES;
do
    mv $file "$file.bck"
done

# Make symbolic links to dev folder
###################################
config_symbolic_links $I3_CONFIG_FILES $DEV_FOLDER "i3"
config_symbolic_links $TERMINATOR_CONFIG_FILES $DEV_FOLDER "terminator"

# Binaries to install manually
##############################
TO_INSTALL="FZF \
            AG \
            zsh-syntax-highlighting \
            nnn \
            tig"

for bin in $TO_INSTALL
do
    echo "Install $bin"
done
