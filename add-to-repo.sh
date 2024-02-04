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
cp ~/.ackrc ~/.bashrc ~/.inputrc ~/.tmux.conf ~/.profile .

# Vim stuff
cp -r ~/.vimrc . 2>/dev/null
cp -r ~/.vim/after .vim/ 2>/dev/null
cp -r ~/.vim/colors .vim 2>/dev/null
cp -r ~/.vim/templates .vim 2>/dev/null

# Nvim
cp -r ~/.config/nvim/init.lua . 2>/dev/null
cp -r ~/.config/nvim/after . 2>/dev/null
cp -r ~/.config/nvim/lua . 2>/dev/null
cp -r ~/.config/nvim/templates . 2>/dev/null

# Terminal profile, if gnome-terminal exists
if test -f /usr/bin/gnome-terminal; then
    dconf dump /org/gnome/terminal/legacy/profiles:/ > gnome_profile.dconf
fi
