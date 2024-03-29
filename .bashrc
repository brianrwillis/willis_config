# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
    else
    color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


############################# Start of Brian stuff ############################

# Machine-dependent, untracked aliases (and related)
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Stubbornly use nvim everywhere
export EDITOR="nvim"
set -o vi

# But I still like these
bind -m vi-insert "\C-p.":previous-history
bind -m vi-insert "\C-n.":next-history
bind -m vi-insert "\C-a.":beginning-of-line
bind -m vi-insert "\C-e.":end-of-line

# Aliases
alias py="python3"
alias go="xdg-open"

alias vi="nvim"
alias iv="nvim"
alias vo="nvim"
alias ov="nvim"

alias :q="echo idiot ; sleep 0.5 ; exit"

alias akc="ack"
alias acj="akc"
alias avk="akc"
alias avj="akc"
alias avl="akc"

alias S="source ~/.bashrc ; source ~/.bash_aliases ; source ~/.profile"

alias cake="make clean ; make"

# Init submodules, *reset all changes*, update submodules
alias sub="git submodule init ; git submodule foreach --recursive git reset --hard ; git submodule update --recursive"

alias gitpush="git push"
alias gitpull="git pull"

# Open all git conflicts
# FIXME check this is working with submodules
con() {
    # Get list of conflicts
    all_files=$(git ls-files -u | cut -f 2 | sort -u)

    # Filter out directories
    non_directories=()
    for x in $all_files; do
        [ -d "$x" ] || non_directories+=("$x")
    done

    # Make sure length is > 0
    if [ ${#non_directories[@]} -ne 0 ]; then
        # Open all up in a separate vim tab
        command $EDITOR -p ${non_directories[@]}
    fi
}

# Stop that
ack() {
    if [[ ($@ == "V") || ($@ == "v") ]]; then
        command echo "stop that"
    else
        command ack "$@"
    fi
}

# Urn!
make() {
    if [[ ($@ == "urn") ]]; then
        command echo "\
         ______
        (______)
          )  (
        ,'    \`.
       (        )
        \`.    .'
          )  (
         /____\\
    "
    else
        command make "$@" | tee
    fi
}

# Git overrrides
git() {
    # Pretty tags list
    if [[ ($@ == "tag") ]]; then
        command git tag --sort=-creatordate

    # Check out a branch, and where possible, check out submodules' branches of the same name. 
    # Trigger when last arg is "all" - hopes no branches are named "all"
    elif [[ (${@: -1} == "all") ]]; then
        if [[ ($# != 3) ]]; then
            echo "Usage: git checkout BRANCH_NAME all"
        else
            # Parent repo
            command git checkout $2

            # For submodules, first checkout the hashes tracked as by the parent repo
            command git submodule update

            # Now check out the branch names - if the branch doesn't exist, do not complain
            # FIXME: git fetch for remote branches?
            command git submodule foreach "git checkout $2 || true" 2>/dev/null
        fi

    # Unmolested git command
    else
        command git "$@"
    fi
}

# Do a little dec -> hex conversion
hex() {
    if [[ ($# == 0) ]]; then
        echo "Usage: hex NUMBER [lower]"
    else
        if [[ ($2 == "lower") ]]; then
            python3 -c "print('0x%x' % $1)"
        else
            python3 -c "print('0x%X' % $1)"
        fi
    fi
}

# Do a little hex -> dec conversion
dec() {
    if [[ ($# == 0) ]]; then
        echo "Usage: dec [0x]NUMBER"
    else
        python3 -c "print('%d' % (int('$1', 0) if '0x' in '$1' else int('0x' + '$1', 0)))"
    fi
}

# find -name "*<thing>*" is too much to fuckin type god damn it
# FIXME: find a nice way to add variable number of options at the end
fin() {
    filter=true
    brian_find "$@"
}

finn() {
    filter=false
    brian_find "$@"
}

brian_find() {
    suds=""

    if [[ ($# == 0) ]]; then
        echo "Usage: fin [dir] term"
    else
        if [[ ($# == 1) ]]; then
            dir=.
            search=$1
        elif [[ ($# == 2) ]]; then
            dir=$1
            search=$2

            if [[ ($1 == "/") ]]; then
                suds="sudo"
            fi
        fi

        if [[ $filter == true ]]; then
            command $suds find "$dir" -name "*$search*" -type f ! -path "*/\.git/*"   \
                                                                ! -path "/*undodir/*" \
                                                                ! -path "*\.so"       \
                                                                ! -path "*\.o"        \
                                                                ! -path "*\.omc"      \
                                                                ! -path "*\.a"        \
                                                                ! -path "*\.elf"      \
                                                                ! -path "*\.bin"      \
                                                                ! -path "*/outputs/*" \
                                                                ! -path "*/build/*"   \
                                                                ! -name "*\.sw[a-p]"  \
                                                                ! -name "tags"        \
                                                                ! -name "Session.vim"      
        else
            command $suds find "$dir" -name "*$search*" 
        fi
    fi
}

# Do a gcc command but also `-I` every single dir in the PWD
# FIXME: this is super dumb
gcc-big-include() {
    if [[ ($# == 0) ]]; then
        echo "Usage: gcc-big-include FILE [extraneous args]"
    else
        all_includes=$(find -type d | grep -v '\.git' | sed 's/^/-I/' | tr '\n\' ' ' 2>/dev/null)
        gcc ${@:2} $1 $all_includes
    fi
}

# Print all the processes using swap space in order
print-swap() {
    for file in /proc/*/status ; do
        awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file
    done | sort -k 2 -n
}

# Restart audio driver
alias audio="systemctl --user restart pulseaudio"

# If we don't study the commands of the past, we're doomed to retype them
HISTSIZE=100000
HISTFILESIZE=100000


# Share bash history across all terminals, avoiding duplicates
HISTCONTROL=ignoredups:erasedups

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# After each command, append to the history file and reread it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"


# Prevent Qt session management errors
unset SESSION_MANAGER

# Remove Ctrl-S freeze
stty -ixon

# Dont close the bash shell after period of no activity
# (WHY DOES THIS EXIST)
export TMOUT=0

# Disable touchscreen
server_type=$(loginctl show-session $(awk '/tty/ {print $1}' <(loginctl)) -p Type | awk -F= '{print $2}')
if [[ $server_type == "xorg" ]]; then
    device=$(xinput --list | grep "Touchscreen" | awk '{print substr($5,4)}')
    if [ ! -z "$device" ]; then
        xinput disable $(xinput --list | grep "Touchscreen" | awk '{print substr($5,4)}')
    fi
fi

# Consistent character interpretation
stty sane
