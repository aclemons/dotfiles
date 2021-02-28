#!/bin/bash

if [[ $- != *i* ]] ; then
    # non-interactive
    return
fi

##########################
# Some stuff from gentoo #
##########################


use_color=false

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
  && type -P dircolors >/dev/null \
  && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
  # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
  if type -P dircolors >/dev/null ; then
    if [[ -f ~/.dir_colors ]] ; then
      eval $(dircolors -b ~/.dir_colors)
    elif [[ -f /etc/DIR_COLORS ]] ; then
      eval $(dircolors -b /etc/DIR_COLORS)
    fi
  fi

  if [[ ${EUID} == 0 ]] ; then
    PS1='\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
  else
    PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
  fi

  alias ls='ls --color=auto'
  alias grep='grep --colour=auto'
else
  if [[ ${EUID} == 0 ]] ; then
    # show root@ when we don't have colors
    PS1='\u@\h \W \$ '
  else
    PS1='\u@\h \w \$ '
  fi
fi

# Try to keep environment pollution down, EPA loves us.
unset use_color safe_term match_lhs

################
# Bash Options #
################

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# match filenames in a case-insensitive fashion when performing filename expansion
shopt -s nocaseglob

# history list is appended to the history file when the shell exits
shopt -s histappend

# do not attempt to search the PATH for possible completions when completion is attempted on an empty line
shopt -s no_empty_cmd_completion

###########
# History #
###########

_bashrc_eternal_history_file=~/.bash_eternal_history

if [ ! -e $_bashrc_eternal_history_file ] ; then
    touch $_bashrc_eternal_history_file
    chmod 0600 $_bashrc_eternal_history_file
fi

unset HISTFILESIZE

HISTCONTROL=ignorespace:ignoredups

function _add_to_history() {
# Change the window title of X terminals
    case ${TERM} in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*|interix)
      echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\007"
    ;;
    screen|screen-256color)
      echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}\033\\"
    ;;
    esac

    # prevent historizing last command of last session on new shells
    if [ $_first_invoke != 0 ] ; then
        _first_invoke=0
        return
    fi

    # remove history position (by splitting)
    local history
    history=$(history 1)

    [ "$_last_history" = "$history" ] && return;

    read -r pos cmd <<< "$history"

    local quoted_pwd=${PWD//\"/\\\"}

    # update cleanup_eternal_history if changed:
    local line="$USER"
    line="$line $(date +'%F %T')"
    line="$line $BASHPID"
    line="$line \"$quoted_pwd\""
    line="$line $cmd"
    echo "$line" >> $_bashrc_eternal_history_file

    _last_history=$history

    history -a
}

function __fzf_eternal_history__() {
  local line
  shopt -u nocaseglob nocasematch
  cat $_bashrc_eternal_history_file |
      FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS --tac --sync -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS +m" $(__fzfcmd) | cut -d' ' -f6-
}

##########
# Prompt #
##########

function _simple_prompt_command() {
  _add_to_history
}

PROMPT_COMMAND=_simple_prompt_command

#######
# GPG #
#######
alias gpg=gpg2
export GPG_TTY="$(tty)"

if pgrep gpg-agent > /dev/null ; then
  echo UPDATESTARTUPTTY | gpg-connect-agent > /dev/null
fi

##############
# Java Stuff #
##############

# give maven more memory
export MAVEN_OPTS="-server -Xmx3G"

export PARINIT="rTbgqR B=.?_A_a Q=_s>|"

############
# Perforce #
############
export P4CONFIG=.p4settings

#########
# Paths #
#########

export PATH=~/bin:~/.local/bin:~/node_modules/bin:~/go/bin:$PATH
export SQLPATH=~/.sqlplus
export NLS_LANG="ENGLISH_NEW ZEALAND.AL32UTF8"

#############
# Init Vars #
#############

# bool to track first invocation for history
_first_invoke=1

export VISUAL=vim

export FZF_DEFAULT_OPTS="--ansi"
export FZF_DEFAULT_COMMAND="fd --type file --color=always --hidden --exclude .git"

if [[ -e /usr/share/fzf/key-bindings.bash ]] ; then
  source /usr/share/fzf/key-bindings.bash
  bind '"\eh": " \C-e\C-u\C-y\ey\C-u`__fzf_eternal_history__`\e\C-e\er\e^"'
fi

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

if uname -s  | grep Darwin > /dev/null ; then
  RUST_SRC_PATH=/usr/local/share/rust/rust_src
else
  RUST_SRC_PATH="/usr/lib$(case "$(uname -m)" in x86_64) echo "64" ;; *) echo "" ;; esac; )/rustlib/src/rust/src"
fi

export RUST_SRC_PATH

export GTAGSLABEL=pygments

export MANPAGER="sh -c 'col -bx | bat -l man -p'"

if [ -e ~/.emacs.d/bin ] ; then
  PATH="$HOME/.emacs.d/bin:$PATH"
  export PATH
fi

###########
# Aliases #
###########

# prompt when overwriting with cp / mv
alias cp="cp -i"
alias mv="mv -i"

# never download stupid snapshots
alias mvn="mvn -nsu -o"

# case insensitive search in less
alias less="less -i"

alias tidyxml="tidy -xml -i -w 1000 -q"

# start x in a screen session so i don't have to leave a tty logged in
if [ -x /bin/loginctl ] ; then
  alias startx="ssh-agent startx -- -nolisten tcp"
else
  alias startx="screen -d -m ssh-agent startx -- -nolisten tcp ; exit"
fi

alias sshnokeys="ssh -o PreferredAuthentications=keyboard-interactive"
alias scpnokeys="scp -o PreferredAuthentications=keyboard-interactive"
alias sftpnokeys="sftp -o PreferredAuthentications=keyboard-interactive"

alias gogo="rlwrap -c telnet localhost 5356"

alias rubclean="rubber --clean"

alias touchpadon="synclient TouchpadOff=0"
alias touchpadoff="synclient TouchpadOff=1"

if [[ $(id -u) == "0" ]] ; then
  function sr() {
    if [[ $1 == install ]] || ([[ $1 == batch ]] && [[ $2 == install ]]); then
      shift

      local package
      for package in "$@" ; do
        local url
        url="$(slackroll urls "$package" | sed -n '$p' | sed 's/\.t.z$//').dep"

        if curl -f -s "$url" -o /dev/null ; then
          local deps
          deps="$(curl -f -s "$url" | sort | paste -s -d' ')"

          # shellcheck disable=SC2086
          slackroll install $deps "$package"
        else
          slackroll install "$package"
        fi
      done
    else
      slackroll "$@"
    fi
  }
fi

[[ -n "$DISPLAY" ]] && alias vim="gvim -v"
[[ -n "$DISPLAY" ]] && alias emacs="TERM=xterm-24bits emacs -nw" && alias emacsclient="TERM=xterm-24bits emacsclient -nw -a '' -c"
[[ -n "$DISPLAY" ]] && alias remacs="remacs -nw" && alias remacsclient="remacsclient -nw -a '' -c"
[[ -z "$DISPLAY" ]] && [[ -e /usr/bin ]] && alias emacs="$(basename "$(find /usr/bin/ -name 'emacs*-no-x11')") -nw" && alias emacsclient="$(basename "$(find /usr/bin/ -name 'emacs*-no-x11')") -nw -a '' -c"

alias ansistrip="perl -e 'use Term::ANSIColor qw(colorstrip); print colorstrip \$_ while <>;'"

# ruby / rails
alias be='bundle exec'
alias bi='NOKOGIRI_USE_SYSTEM_LIBRARIES=1 bundle install'
alias rtdb='bundle exec rake db:environment:set db:drop db:create db:test:prepare db:environment:set RAILS_ENV=test'

##################
# Misc Functions #
##################

function rubpdf() {
  if [ $# -ne 1 ] ; then
    echo "Usage: rubpdf [tex file]"
    return 1
  fi

  local tex="$1"
  echo "Rubbing $tex"
  for i in {1..3}; do
    rubber --inplace --maxerr -1 --short --force --warn all --pdf "$tex"
  done

  xdg-open "${tex%tex}pdf"
}

function rubhtml() {
  if [ $# -ne 1 ] ; then
    echo "Usage: rubhtml [tex file]"
    return 1
  fi

  local tex="$1"
  echo "Rubbing $tex"
  for i in {1..3}; do
    rubber --inplace --maxerr -1 --short --force --warn all --html "$tex"
  done

  xdg-open "${tex%tex}html"
}

function bundledate() {
  if [ $# -ne 1 ] ; then
    echo "Usage: bundledate [jar file]"
    return 1
  fi

  local arg="$1"

  if [ ! -e "$arg" ] ; then
    echo "$arg does not exist!"
    return 2
  fi

  bnddate="$(unzip -q -c "$arg"  META-INF/MANIFEST.MF | perl -0pe 's/\r?\n //sg' | perl -pe 's/\r\n/\n/g' | grep Bnd-LastModified)"

  if [ ! $? = 0 ] ; then
    echo "$arg does not have a Bnd-LastModified manifest entry"
    return 3
  fi

  date -d @$(( $(echo "$bnddate" | cut -d' ' -f2) / 1000 ))

}

function manifest() {
  if [ $# -ne 1 ] ; then
    echo "Usage: manifest [jar file]"
    return 1
  fi

  local arg="$1"

  if [ ! -e "$arg" ] ; then
    echo "$arg does not exist!"
    return 2
  fi

  unzip -q -c "$arg" META-INF/MANIFEST.MF | perl -0pe 's/\r?\n //sg' | perl -pe 's/\r\n/\n/g'
}

function timeis() {
  if [ $# -ne 1 ] ; then
    echo "Usage: timeis [place]"
    return 1
  fi

  local search="$1"

  search=${search/ /_}

  w3m -dump "http://time.is/$search" | grep --colour=never -i -P "\d\d:\d\d:\d\d|^Time in | week "
}

# translate a word
function tl() {
  w3m -dump "https://dict.leo.org/englisch-deutsch/$@" \
    | sed '1,/Aktivieren Sie JavaScript für mehr Features/d' \
    | sed '1d' \
    | sed '/Weitere Aktionen/Q' \
    | sed '$d'
}

# find mvn project by groupId/artefact id under the current dir
# Exit codes
#  0 - found
#  1 - no matching project found
function find_mvn_project() {
  if [ $# -ne 1 -a $# -ne 2 ] ; then
    echo "Usage: find_mvn_project [artefactId] | [groupId] [artefactId]"
    return 1
  fi

  if [ $# -eq 1 ] ; then
    find . -name pom.xml -print0 | xargs -I xx -0 sh -c "(xmllint --xpath \"/*[local-name()='project' and *[local-name()='artifactId' and text()='$1']]\" xx > /dev/null 2>&1 && echo xx) || true" | grep .
  else
    find . -name pom.xml -print0 | xargs -I xx -0 sh -c "(xmllint --xpath \"/*[local-name()='project' and *[local-name()='artifactId' and text()='$2'] and ((*[local-name()='parent']/*[local-name()='groupId' and text()='$1'] and not(*[local-name()='groupId' and text()='$1'])) or (*[local-name()='groupId' and text()='$1']))]\" xx > /dev/null 2>&1 && echo xx) || true" | grep .
  fi
}

function goto_mvn_project() {
  local pom="$(find_mvn_project $*)"

  [ ! -z "$pom" ] || (>&2 echo "Project not found" && return 1)

  cd "$(dirname "$pom")"
}

function countdown {
  while true; do echo -ne "$(date)\\r"; done
}

function diff_multimodule {
  if [ $# -ne 2 ] ; then
    echo "Usage: diff_multimodule treeish1 treeish2"
    return 1
  fi

  git submodule foreach -q 'sh -c "git diff '"$1..$2"' -- . | filterdiff --clean --addprefix '\'' $path/'\'' -x '\''*/*Test.java'\'' -x '\''*/pom.xml'\'' -x '\''*/category.xml'\'' -x '\''*/feature.xml'\'' -x '\''*/MANIFEST.MF'\'' -x '\''*/*.product'\'' -x '\''*/readme.txt'\'' -x '\''*/src/test/*'\''"'
}

function update_vim_plugins() {
  find "$HOME/.vim/bundle" -type d -mindepth 1 -maxdepth 1 | sed 's/\.\///' | xargs -I xx git --git-dir=xx/.git checkout master
  find "$HOME/.vim/bundle" -type d -mindepth 1 -maxdepth 1 | sed 's/\.\///' | xargs -I xx git --git-dir=xx/.git pull --rebase
}

# create functions for elvis which support reading from stdin
# like 'blah | vim -' does
#
# call elvis with TERM=xterm so it works inside tmux
function elvis {
  local BINARY_NAME="elvis"
  local BINARY="/usr/bin/$BINARY_NAME"
  local LAST=""

  if [ $# -gt 0 ] ; then
    LAST="${*: -1}"
  fi

  if [ "x$LAST" = "x-" ] ; then
    local TMPFILE
    TMPFILE="$(mktemp)"

    local ARGS=()
    if [ $# -gt 1 ] ; then
      local LENGTH=$(($#-1))
      ARGS="${*:1:$LENGTH}"
    fi

    ARGS+=("$TMPFILE")

    cat > "$TMPFILE" && </dev/tty LANG=de_DE@euro TERM=xterm "$BINARY" "${ARGS[@]}" ; rm "$TMPFILE"
  else
    LANG=de_DE@euro TERM=xterm "$BINARY" "$@"
  fi
}
