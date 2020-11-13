export QT_QPA_PLATFORMTHEME="qt5ct"
export EDITOR=/usr/bin/vim
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
# fix "xdg-open fork-bomb" export your preferred browser from here
export BROWSER=/usr/bin/chromium

# modified by akatsuki
# OLDPWD is the $GOPATH/bin
export PATH=$PATH:$HOME/go/bin
# yarn bin
export PATH=$PATH:$(yarn global bin)
