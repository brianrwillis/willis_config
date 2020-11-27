# Any computer-specific bashrc settings

# Aliases
alias cos="cd $HOME/repos/cosmos-environment"
alias seq="cd $HOME/repos/sequoia"
alias whit="cd $HOME/repos/whitney"
alias egse="cd $HOME/repos/capella-egse-msps"
alias ops="cd $HOME/repos/operations-scripts"
alias plat="cd $HOME/repos/msp430-platform"
alias ans="cd $HOME/repos/ansible"
alias pen="cd $HOME/repos/capella-penguin"
alias bill="cd $HOME/repos/capella-bill"
alias bbb="cd $HOME/repos/capella-bbb"
alias gau="cd $HOME/repos/capella-gauntlet"
alias core="cd $HOME/repos/core-seq"
alias beak="cd $HOME/repos/capella-beak"
alias wing="cd $HOME/repos/capella-wing"
alias cache="cd $HOME/.cache/capella-aviary"

alias cake="omake clean && omake"
alias ckae="cake"
alias ckea="cake"

alias omaek="omake"
alias oamke="omake"
alias omkae="omake"
alias omke="omake"
alias oamek="omake"
alias omae="omake"
alias o,ake="omake"
alias oamake="omake"
alias omkaek="omake"
alias omakw="omake"
alias omakem="omake"
alias omakm="omake"
alias omak="omake"
alias okmae="omake"
alias oaeke="omake"
alias oake="omake"
alias iomaje="omake"
alias imaje="omake"
alias inaje="omake"

alias ssh-trisolaris="ssh capella@10.57.7.150"
alias ssh-namek="ssh capella@10.57.7.235"
alias ssh-endor="ssh dev_endor_testbed"
alias ssh-dendor="ssh dev_endor"
alias ssh-hyperion="ssh dev_hyperion_testbed"
alias ssh-dhyperion="ssh dev_hyperion"
alias ssh-kerbin="ssh dev_kerbin_testbed"
alias ssh-dkerbin="ssh dev_kerbin"

alias sub="git pull --recurse-submodules && git submodule update --init --recursive"

alias fcs-gdb="LD_LIBRARY_PATH=/opt/Microsemi_SoftConsole_v6.0/openocd/bin arm-none-eabi-gdb -ex 'target remote | /opt/Microsemi_SoftConsole_v6.0/openocd/bin/openocd -c \"gdb_port pipe; set DEVICE M2S090\" -f board/microsemi-cortex-m3.cfg'"

# Access token
export GITLAB_PAT=TSX6ygABqv1ramd_htuC

# Cosmos
export COSMOS_ENV_PATH="$HOME/repos/cosmos-environment"
export PATH="$HOME/.rbenv/libexec:$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Microsemi + MSP
export PATH="$PATH:/opt/Microsemi_SoftConsole_v6.0/arm-none-eabi-gcc/bin"
export SC_INSTALL_DIR="/opt/Microsemi_SoftConsole_v6.0"
export PATH=$PATH:"/opt/capella-msp430/bin"
export LD_LIBRARY_PATH="/opt/Microsemi_SoftConsole_v6.0/openocd/bin"

# Omake f a s t
export OMAKEFLAGS=-j10

# Logic
export PATH=$PATH:"/home/brianwillis/Logic"

# Ignore pip warnings
export PYTHONWARNINGS="ignore:Unverified HTTPS request"

# capella-emperor-penguin -t 99999 -s update_software -c ~/BRW_ENDOR/penguin.local.json -i 0 -a "--generation sequoia --version v7.2.9 --override-spitz-ipaddress dev_endor --cdh-core --cdh-bootloaders STAGE_0 IMAGE_1 IMAGE_2 --cdh-tables --cdh-startup --cdh-sramjet --cdh-images IMAGE_A IMAGE_B --cdh-apps ALL --msps ALL"

# gcc -E bbb/bsp/x86/src/bsp_i2c.c $(find -type d | sed 's/^/-I/' | tr '\n\' ' ')
