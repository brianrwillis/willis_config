# Double check :)
read -p "Overwrite config files in repo with what exists locally? [Y/n]" -n 1 -r -s
echo ""

if ! [[ ($REPLY =~ ^[Yy]$) || (-z $REPLY) ]]; then
    # GTFO
    echo "Aborting!"
    exit 1
fi

echo "Updating..."

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
