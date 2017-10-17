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

# matche filenames in a case-insensitive fashion when performing filename expansion
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
HISTIGNORE="truecrypt*":?:??

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
    local history=$(history 1)

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

function h() {

    if [ "$*" = "" ] ; then
        tail -100 $_bashrc_eternal_history_file
        return
    fi

    grep -i "$*" $_bashrc_eternal_history_file | tail -100
}


##########
# Prompt #
##########

function _simple_prompt_command() {
  _add_to_history
}

PROMPT_COMMAND=_simple_prompt_command

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

export PATH=~/bin:~/.local/bin:~/node_modules/.bin:$PATH
export SQLPATH=~/.sqlplus
export NLS_LANG="ENGLISH_NEW ZEALAND.AL32UTF8"

#############
# Init Vars #
#############

# bool to track first invocation for history
_first_invoke=1

export VISUAL=vim

export FZF_DEFAULT_COMMAND='ag -l -g ""'

RUST_SRC_PATH="/usr/lib$(case "$(uname -m)" in x86_64) echo "64" ;; *) echo "" ;; esac; )/rustlib/src/rust/src"
export RUST_SRC_PATH

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
alias startx="screen -d -m ssh-agent startx -- -nolisten tcp ; exit"

alias sshnokeys="ssh -o PreferredAuthentications=keyboard-interactive"
alias scpnokeys="scp -o PreferredAuthentications=keyboard-interactive"

alias gogo="rlwrap -c telnet localhost 5356"

alias rubclean="rubber --clean"

alias touchpadon="synclient TouchpadOff=0"
alias touchpadoff="synclient TouchpadOff=1"

[[ ! -z "$DISPLAY" ]] && alias vim="gvim -v"
alias emacs="emacs -nw"
alias emacsclient="emacsclient -nw -a '' -c"

alias ansistrip="perl -e 'use Term::ANSIColor qw(colorstrip); print colorstrip \$_ while <>;'"

# ruby / rails
alias be='bundle exec'
alias bi='NOKOGIRI_USE_SYSTEM_LIBRARIES=1 bundle install'
alias rtdb='bundle exec rake db:environment:set db:drop db:create db:test:prepare db:environment:set RAILS_ENV=test'

# powershop
alias au='PS_MARKET=au'
alias nz='PS_MARKET=nz'
alias uk='PS_MARKET=uk'
alias wipssh='RLWRAP_HOME="$HOME/.rlwrap" rlwrap -a ssh'
alias review_filter="filterdiff -x '*/spec/*' -x '*/features/*'"

export RUBY_GC_HEAP_INIT_SLOTS=500000
export RUBY_HEAP_SLOTS_INCREMENT=500000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1.0
export RUBY_GC_MALLOC_LIMIT=50000000

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

  local city="$1"
  local search="$1"

  search=${search/ /_}

  w3m -dump http://time.is/$search | grep --colour=never -i -P "\d\d:\d\d:\d\d|^Time in | week "
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
  while true; do echo -ne "$(date)\r"; done
}

function diff_multimodule {
  if [ $# -ne 2 ] ; then
    echo "Usage: diff_multimodule treeish1 treeish2"
    return 1
  fi

  git submodule foreach -q 'sh -c "git diff '"$1..$2"' -- . | filterdiff --clean --addprefix '\'' $path/'\'' -x '\''*/*Test.java'\'' -x '\''*/pom.xml'\'' -x '\''*/category.xml'\'' -x '\''*/feature.xml'\'' -x '\''*/MANIFEST.MF'\'' -x '\''*/*.product'\'' -x '\''*/readme.txt'\'' -x '\''*/src/test/*'\''"'
}

# create functions for vi / elvis which support reading from stdin
# like 'blah | vim -' does
#
# call vi/elvis with TERM=xterm so it works inside tmux
function vi {
  local BINARY_NAME="vi"
  if [ "x${FUNCNAME[1]}" = "xelvis" ] ; then
    local BINARY_NAME="elvis"
  fi

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

function elvis {
  vi "$@"
}

function ks_env {
  if [ $# -gt 2 ] || [ $# -lt 1 ] ; then
    printf "Usage: ks_env [nz|au|uk] [--partial]\n"
    return 1
  fi

  partial=false
  if [ "x--partial" = "x$1" ] ; then
    partial=true
    shift
  fi

  if [ "$1" = "au" ] || [ "$1" = "nz" ] || [ "$1" = "uk" ] ; then
    if [ "x$2" = "x--partial" ] ; then
      partial=true
    elif [ "x$2" = "x" ] ; then :
    else
      printf "Usage: ks_env [nz|au|uk] [--partial]\n"
      return 1
    fi
  else
    printf "Usage: ks_env [nz|au|uk] [--partial]\n"
    return 1
  fi

  if $partial && [ ! -f script/partial_ks.rb ] ; then
    printf "script/partial_ks.rb must exist in the current directory\n"
    return 2
  fi

  printf "Syncing structure...\n\n"

  if [ "x$1" = "xnz" ] ; then
    host="$1-wip-host-akl1"
  else
    host="$1-wip-host-wlg1"
  fi

  macosx=false
  case "$(uname)" in
    Darwin) macosx=true;;
  esac

  if $macosx ; then
    nprocs="$(ruby -e 'require "concurrent"; puts Concurrent.processor_count')"
  else
    nprocs="$(nproc)"
  fi

  ks --structure-only --workers="$nprocs" --commit=often --alter --via="$host" --from=mysql://wip@127.0.0.1:3306/powershop_production --to="mysql://root@localhost/powershop_development_$1" || return "$?"

  printf "\n"

  printf "Enabling compression for all tables...\n"

  mysql -B -h localhost -u root -e 'show tables' "powershop_development_$1" | sed -e '1d' | while read -r table ; do
    if ! mysql -B -h localhost -u root -e "show create table $table" "powershop_development_$1"  | grep "ROW_FORMAT=COMPRESSED" > /dev/null 2>&1 ; then
      printf "alter table %s ROW_FORMAT=COMPRESSED;\n" "$table"
    fi
  done | mysql -B -h localhost -u root "powershop_development_$1" || return "$?"

  printf "\n"

  printf "Syncing data...\n\n"

  if $partial ; then
    PS_MARKET="$1" ruby script/partial_ks.rb || return "$?"
  else
    ks --workers="$nprocs" --commit=often --alter --via="$host" --from=mysql://wip@127.0.0.1:3306/powershop_production --to="mysql://root@localhost/powershop_development_$1" || return "$?"
  fi

  printf "\n"
}

function diff_local_migrations {
  vimdiff <(printf "%s\nexit\n" 'ActiveRecord::Base.connection.execute("select version from schema_migrations order by version").to_a.join(" ")' | PS_MARKET="au" bundle exec rails c | sed '/^=> "/!d' | sed 's/=> //;s/"//g' | tr ' ' '\n' | sort) <(ls -A db/migrate/ | awk -F_ '{ print $1 }')
}
