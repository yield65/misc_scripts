autoload -Uz down-line-or-beginning-search
autoload -Uz up-line-or-beginning-search

if test -x /usr/bin/dircolors ; then
        #
        # set up the color-ls environment variables:
        #
        if test -f $HOME/.dir_colors ; then
            eval "`/usr/bin/dircolors -b $HOME/.dir_colors`"
        elif test -f /etc/DIR_COLORS ; then
            eval "`/usr/bin/dircolors -b /etc/DIR_COLORS`"
        fi
fi

alias la="ls $LS_OPTIONS -la"
alias lld="ls $LS_OPTIONS -ld .*"
alias ll="ls $LS_OPTIONS -l"
alias l="ls $LS_OPTIONS"
alias ls="ls $LS_OPTIONS"

#alias apg1='apg -a1 -m16 -x24 -M SNCL -c /dev/random'
#alias apg0='apg -a0 -n6 -l -t -m 10 -x 16 -c /dev/random'
alias genpass='pwgen -1 16 1'
alias gensec='pwgen -1 -s -y 16 1'

alias su='su -'
alias most='most -w'

alias es-keymap='localectl set-keymap --no-convert es'
alias us-keymap='localectl set-keymap --no-convert us'

bindkey -v
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey "^R" history-incremental-pattern-search-backward
bindkey "^S" history-incremental-pattern-search-forward

bindkey '\e[A' up-line-or-beginning-search
bindkey '\e[B' down-line-or-beginning-search
bindkey '\eOA' up-line-or-beginning-search
bindkey '\eOB' down-line-or-beginning-search

export GOPATH=~/goprojects
export BC_ENV_ARGS=~/.bcrc
export CHROMIUM_USER_FLAGS="--process-per-site --incognito --disable-sync-preferences --cipher-suite-blacklist=0x0001,0x0002,0x0004,0x0005,0x0017,0x0018,0xc002,0xc007,0xc00c,0xc011,0xc016,0xff80,0xff81,0xff82,0xff83"
export EDITOR=vim
export PAGER="/usr/bin/most -w"
export MANPAGER="/usr/bin/most -w -s"
export HISTSIZE=128
export KEYTIMEOUT=1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/yield/lib
export LD_RUN_PATH=$LD_RUN_PATH:/home/yield/lib
export LS_OPTIONS="$LS_OPTIONS --group-directories-first -h"
export PATH=$PATH:$GOPATH/bin:/home/yield/bin:/usr/local/bin:/usr/bin:/bin:/usr/bin/X11:/usr/X11R6/bin:/usr/games:/opt/kde3/bin:/usr/lib/mit/bin:/home/yield/repositories/testing/scripts:/home/yield/.local/bin:/snap/bin
export PYTHONPATH=${PYTHONPATH}:/home/yield/repositories/pygraphml/
export SAVEHIST=128
export STAR_COMPRESS_FLAG="-9"
export UPDATE_ZSH_DAYS=13

HIST_STAMPS="dd.mm.yyyy"
HISTIGNORE='&:clear:ls:cd:[bf]g:exit:[ t\]*'

setopt APPEND_HISTORY
setopt NO_HUP
setopt correct
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt histignorespace
setopt hist_no_store
setopt HISTREDUCEBLANKS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY
setopt VI
unsetopt correct_all

#plugins=(git sprunge ubuntu rsync systemd wd vi-mode aws)
plugins=(git sprunge rsync systemd vi-mode aws python pyenv)

source ~/.functions

zle -N down-line-or-beginning-search
zle -N up-line-or-beginning-search
ZSH_THEME=candy
ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

