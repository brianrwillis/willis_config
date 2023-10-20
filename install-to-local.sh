# Double check :)
read -p "Overwrite local config files with what exists in this repo? [Y/n]" -n 1 -r -s
echo ""

if ! [[ ($REPLY =~ ^[Yy]$) || (-z $REPLY) ]]; then
    # GTFO
    echo "Aborting!"
    exit 1
fi

echo "Updating..."

# Vim dirs
mkdir ~/.vim         2>/dev/null
mkdir ~/.vim/after   2>/dev/null
mkdir ~/.vim/colors  2>/dev/null
mkdir ~/.vim/undodir 2>/dev/null

# Copy to home dir
cp -r --parents .bashrc .profile .ackrc .inputrc .tmux.conf .vimrc .vim ~

# Terminal profile, if gnome-terminal exists
if test -f /usr/bin/gnome-terminal; then
    dconf load /org/gnome/terminal/legacy/profiles:/ < gnome_profile.dconf
fi

echo "Successfully updated local configs"

