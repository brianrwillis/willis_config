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
