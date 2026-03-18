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
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

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
alias vscode="/mnt/c/Users/Admin/AppData/Local/Programs/Microsoft\ VS\ Code/Code.exe"
export HISTSIZE=100000
export HISTFILESIZE=200000
PS1="\u@\h:\w\$ "

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


parse_git_repo_and_path() {
  local root head repo rel

  root=$(git rev-parse --show-toplevel 2>/dev/null) || return
  head=$(git rev-parse --short HEAD 2>/dev/null) || return
  repo=$(basename "$root")

  if [[ "$PWD" == "$root" ]]; then
    printf '%s(%s)' "$repo" "$head"
    return
  fi

  rel="${PWD#"$root"/}"
  printf '%s/%s(%s)' "$repo" "$rel" "$head"
}

PS1='$(parse_git_repo_and_path 2>/dev/null || printf "\W")\$ '

alias glog='git log --graph --oneline --all --decorate --date-order'
alias glog6='git --no-pager log --graph --oneline --all --decorate --date-order -6'
alias glogt='git log --graph --oneline --all --decorate --date-order --format="%C(auto)%h %d %s %C(black)%C(bold)- %cr"'
alias glg='git log --graph --oneline --decorate --date-order'

# Jump to git repository root, or to a path inside it.
groot() {
  local root

  root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    echo "Not in a git repository" >&2
    return 1
  }

  if [[ -n "$1" ]]; then
    cd "$root/$1" || return 1
  else
    cd "$root" || return 1
  fi
}

# Print git repository root path.
alias gpwd='git rev-parse --show-toplevel'

alias bashrc='bash -n ~/.bashrc && source ~/.bashrc'

__prompt_repo_path() {
  local top root rel

  top="$(git rev-parse --show-toplevel 2>/dev/null)" || {
    printf '%s' '\w'
    return
  }

  root="$(basename "$top")"
  rel="${PWD#$top}"
  rel="${rel#/}"

  if [[ -n "$rel" ]]; then
    printf '%s/%s' "$root" "$rel"
  else
    printf '%s' "$root"
  fi
}

__prompt_git_ref() {
  local ref

  ref="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)" && {
    printf '%s' "$ref"
    return
  }

  ref="$(git rev-parse --short HEAD 2>/dev/null)" || return
  printf 'detached@%s' "$ref"
}

__prompt_git_dirty() {
  git diff --no-ext-diff --quiet --cached 2>/dev/null || {
    printf '*'
    return
  }

  git diff --no-ext-diff --quiet 2>/dev/null || {
    printf '*'
    return
  }
}

__set_ps1() {
  local exit_code=$?
  local path ref dirty

  path="$(__prompt_repo_path)"
  ref="$(__prompt_git_ref)"
  dirty="$(__prompt_git_dirty)"

  if [[ "$path" == '\w' ]]; then
    PS1='\[\e[1;96m\]\w\[\e[0m\]'
  else
    PS1="\[\e[1;96m\]${path}\[\e[0m\]"
  fi

  if [[ -n "$ref" ]]; then
    PS1+="\[\e[1;93m\](${ref}${dirty})\[\e[0m\]"
  fi

  if (( exit_code != 0 )); then
    PS1+=" \[\e[1;91m\]!${exit_code}\[\e[0m\]"
  fi

  PS1+='\$ '
}

PROMPT_COMMAND=__set_ps1
