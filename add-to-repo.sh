# Confs
cp ~/.ackrc ~/.bashrc ~/.inputrc ~/.tmux.conf ~/.profile ~/.vimrc .

# Vim stuff
cp -r ~/.vim/after .vim/
cp -r ~/.vim/colors .vim
cp -r ~/.vim/templates .vim

# Terminal profile, if gnome-terminal exists
if test -f /usr/bin/gnome-terminal; then
    dconf dump /org/gnome/terminal/legacy/profiles:/ > gnome_profile.dconf
fi
