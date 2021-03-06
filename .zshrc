# Created by Charles Gueunet <charles.gueunet+zsh@gmail.com>

# Follow the link (if any) to find the config folder
if [ -L $HOME/.zshrc ]; then
   export ZDOTDIR=$(dirname `readlink -f $HOME/.zshrc`)
else
   export ZDOTDIR=${HOME}/.config/zsh/
fi

# Source grml
if [[ -s "${ZDOTDIR:-$HOME}/grml/zshrc" ]]; then
   source "${ZDOTDIR:-$HOME}/grml/zshrc"
fi

# Plugin manager (Zplug)
export ZPLUG_HOME=$ZDOTDIR/zplug/
if [[ ! -a ${ZPLUG_HOME} ]]; then
   git clone  --recursive --depth 1 https://github.com/zplug/zplug $ZPLUG_HOME
fi
source ${ZPLUG_HOME}/init.zsh

# Plugins list
source ${ZDOTDIR}/plugins_list.zsh
if [[ -a ${ZDOTDIR}/plugins_custom_list.zsh ]]; then
   source ${ZDOTDIR}/plugins_custom_list.zsh
fi

# Plugins configuration
source ${ZDOTDIR}/plugins_conf.zsh
if [[ -a ${ZDOTDIR}/plugins_custom_conf.zsh ]]; then
   source ${ZDOTDIR}/plugins_custom_conf.zsh
fi

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
   printf "Install? [y/N]: "
   if read -q; then
      echo; zplug install
   fi
fi

# Then, source plugins and add commands to $PATH
zplug load

# Global setting

# cdr allows to come back to a previous visited directory
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# Setopt

# If I could disable Ctrl-s completely I would!
setopt NO_FLOW_CONTROL

# beeps are annoying
setopt NO_BEEP

# avoid automatic change the title
DISABLE_AUTO_TITLE=true

# Glob is clever research / completion
setopt NO_CASE_GLOB
setopt EXTENDED_GLOB
setopt NUMERIC_GLOB_SORT
setopt GLOB_COMPLETE

# Remove annoying file redirection error
setopt CLOBBER

# Job control
setopt monitor

# autocomplete

zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
# fuzzy completion when mistype
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# history

setopt APPEND_HISTORY

# ignore command starting with a space in history
setopt HIST_IGNORE_SPACE

# remove duplicate blanks
setopt HIST_REDUCE_BLANKS

# key binding

# Tab -> complete or next completion
bindkey '^i' expand-or-complete-prefix

# vi mode
bindkey -v
bindkey -M viins "$key_info[Control]P" up-line-or-search
bindkey -M viins "$key_info[Control]N" down-line-or-search
bindkey -M viins "$key_info[Control]R" history-incremental-search-backward
bindkey -M viins "$key_info[Up]" up-line-or-search
bindkey -M viins "$key_info[Down]" down-line-or-search
if zplug check 'modules/autosuggestions'; then
    bindkey -M viins "$key_info[Control]Y" vi-end-of-line
    bindkey -M viins "$key_info[Control]F" vi-forward-word
fi

# Alias

# builtin
alias ls="ls --color -h --group-directories-first -X"
alias sz="source $HOME/.zshrc"
alias sue="su; exit"

# cmake
alias b="mkdir build; cd build"
alias rb="rm -rf build/"
alias nb="rb; b"
alias rmcmake="rm -rf CMakeFiles Makefile cmake_install.cmake CMakeCache.txt build.ninja rules.ninja"

alias -g ECC="-DCMAKE_EXPORT_COMPILE_COMMANDS=1"
alias -g BB="--build build"
alias -g BP="--build ."
alias -g TI="--target install"
alias -g MP="-- -j 6 -l 5"

# git
alias gitgraph="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"

# tmux
alias t="tmux -2"
alias ta="tmux -2 a"

# Keyboard qwerty with accent
# and "," (leader) on Caps Lock
if [[ -f "${HOME}/.Xmodmap" ]]; then
   alias rebind="setxkbmap -option compose:ralt ; xmodmap ${HOME}/.Xmodmap"
else
   alias rebind='setxkbmap -option compose:ralt'
fi

# Alias post command

alias -g G="| grep"
alias -g L="| less"
alias -g T="| tee -a "
alias -g S="| sed"
alias -g V="| vim - "
alias -g X="| xclip"
alias -g XX="\`xclip -o\`"

alias -s {bib,h,c,hpp,cpp,rb,py,cmake,tex,txt,html,xml}=$EDITOR

alias -s {vtu,vti,vtp,stl}=paraview

# Env
export VISUAL="vim"
export EDITOR=$VISUAL
export SVN_EDITOR=$EDITOR
export GIT_EDITOR=$EDITOR
export KEYTIMEOUT=1

# true color vim / tmux
# if [[ -z $TMUX && -z $STY ]]; then
#    export TERM='xterm-256color'
# fi

# Functions

# man inside vim with completion
vman () {
   MANWIDTH=150 MANPAGER='col -bx' man $@ | vim -R -c "set ft=man" -
}
fpath=($ZDOTDIR/completion/ $fpath)

# ctrl z back and forth
fancy-ctrl-z () {
if [[ $#BUFFER -eq 0 ]]; then
   BUFFER="fg"
   zle accept-line
else
   zle push-input
   zle clear-screen
fi
}
zle -N fancy-ctrl-z
bindkey '' fancy-ctrl-z

#vim edit
autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# vi indicator
precmd() {
   RPROMPT=""
   print ""
}
zle-keymap-select() {
RPROMPT=""
[[ $KEYMAP = vicmd ]] && RPROMPT='[%F{yellow}NORMAL%F{reset}]'
() { return $__prompt_status }
zle reset-prompt
}
zle-line-init() {
typeset -g __prompt_status="$?"
}
zle -N zle-keymap-select
zle -N zle-line-init

# ctrl space complete
bindkey ' ' expand-or-complete-with-indicator

# file manager
vicd()
{
   # from https://wiki.vifm.info/index.php?title=How_to_set_shell_working_directory_after_leaving_Vifm
   # Syncro vifm and shell
   local dst="$(command vifm --choose-dir - .)"
   if [ -z "$dst" ]; then
      echo 'Directory picking cancelled/failed'
      return 1
   fi
   cd "$dst"
}
vifm-call() {
if [[ -z $BUFFER ]]; then
  # interpreted at start, not when leaving
  BUFFER="vicd"
  zle accept-line
fi
}
zle -N vifm-call
bindkey '' vifm-call

substitute-last() {
# interpreted at start, not when leaving
BUFFER="!!:gs/"
CURSOR=6
}
zle -N substitute-last
bindkey '' substitute-last

function su {
   # Fix for zplug, we don't want the new user to share ZPLUG variables
    command su -l $@
}

# Facade to zplug
function plugins(){
   zplug $@
}

# Empty command = clear
magic-enter () {
   if [[ -z $BUFFER ]]; then
      zle clear-screen
   else
      zle accept-line
   fi
}
zle -N magic-enter
bindkey "" magic-enter

# Ctrl o: previous vim like
magic-popd () {
   if [[ -z $BUFFER ]]; then
      popd
      zle accept-line
   fi
}
zle -N magic-popd
bindkey "" magic-popd

# Other conf

# fuzzy completion with ctrl-r / ctrl-t / alt-c
if [[ -f "${ZDOTDIR}/fzf_binding.zsh" ]]; then
   source "${ZDOTDIR}/fzf_binding.zsh"
fi

if [[ -f "${ZDOTDIR}/LS_COLORS" ]]; then
   eval $(dircolors -b "${ZDOTDIR}/LS_COLORS")
fi

# Custom conf (in $ZDOTDIR or $HOME)
if [[ -f "${ZDOTDIR}/zshrc_custom.zsh" ]]; then
   source "${ZDOTDIR}/zshrc_custom.zsh"
fi

