# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac

# Path to your oh-my-bash installation.
export OSH=~/.oh-my-bash

POWERLINE_PROMPT=${POWERLINE_PROMPT:="user_info cwd"}

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-bash is loaded.
OSH_THEME="gallifrey"
# OSH_THEME="powerline"
# OSH_THEME="demula"
# OSH_THEME="clean"
# OSH_THEME="random"

# If you set OSH_THEME to "random", you can ignore themes you don't like.
# OMB_THEME_RANDOM_IGNORED=("powerbash10k" "wanelo")

# Uncomment the following line to use case-sensitive completion.
# OMB_CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# OMB_HYPHEN_SENSITIVE="false"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_OSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you don't want the repository to be considered dirty
# if there are untracked files.
# SCM_GIT_DISABLE_UNTRACKED_DIRTY="true"

# Uncomment the following line if you want to completely ignore the presence
# of untracked files in the repository.
# SCM_GIT_IGNORE_UNTRACKED="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.  One of the following values can
# be used to specify the timestamp format.
# * 'mm/dd/yyyy'     # mm/dd/yyyy + time
# * 'dd.mm.yyyy'     # dd.mm.yyyy + time
# * 'yyyy-mm-dd'     # yyyy-mm-dd + time
# * '[mm/dd/yyyy]'   # [mm/dd/yyyy] + [time] with colors
# * '[dd.mm.yyyy]'   # [dd.mm.yyyy] + [time] with colors
# * '[yyyy-mm-dd]'   # [yyyy-mm-dd] + [time] with colors
# If not set, the default value is 'yyyy-mm-dd'.
# HIST_STAMPS='yyyy-mm-dd'

# Uncomment the following line if you do not want OMB to overwrite the existing
# aliases by the default OMB aliases defined in lib/*.sh
# OMB_DEFAULT_ALIASES="check"

# Would you like to use another custom folder than $OSH/custom?
# OSH_CUSTOM=/path/to/new-custom-folder

# To disable the uses of "sudo" by oh-my-bash, please set "false" to
# this variable.  The default behavior for the empty value is "true".
OMB_USE_SUDO=false

# To enable/disable display of Python virtualenv and condaenv
# OMB_PROMPT_SHOW_PYTHON_VENV=true  # enable
# OMB_PROMPT_SHOW_PYTHON_VENV=false # disable

# Which completions would you like to load? (completions can be found in ~/.oh-my-bash/completions/*)
# Custom completions may be added to ~/.oh-my-bash/custom/completions/
# Example format: completions=(ssh git bundler gem pip pip3)
# Add wisely, as too many completions slow down shell startup.
completions=(
  system
)

# Which aliases would you like to load? (aliases can be found in ~/.oh-my-bash/aliases/*)
# Custom aliases may be added to ~/.oh-my-bash/custom/aliases/
# Example format: aliases=(vagrant composer git-avh)
# Add wisely, as too many aliases slow down shell startup.
aliases=(
)

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-bash/plugins/*)
# Custom plugins may be added to ~/.oh-my-bash/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  nvm
  pyenv
)

# Which plugins would you like to conditionally load? (plugins can be found in ~/.oh-my-bash/plugins/*)
# Custom plugins may be added to ~/.oh-my-bash/custom/plugins/
# Example format:
#  if [ "$DISPLAY" ] || [ "$SSH" ]; then
#      plugins+=(tmux-autoattach)
#  fi

source "$OSH"/oh-my-bash.sh

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-bash libs,
# plugins, and themes. Aliases can be placed here, though oh-my-bash
# users are encouraged to define aliases within the OSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias bashconfig="mate ~/.bashrc"
# alias ohmybash="mate ~/.oh-my-bash"

OMB_PLUGIN_NVM_AUTO_USE=true

if uname -s | grep Darwin > /dev/null ; then
  export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"

  if [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] ; then
    # shellcheck disable=SC1091
    . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
  fi
fi

################
# Bash Options #
################

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# match filenames in a case-insensitive fashion when performing filename expansion
shopt -s nocaseglob

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

function _add_to_history() {
    # prevent historizing last command of last session on new shells
    if [ $_first_invoke != 0 ] ; then
        _first_invoke=0
        return
    fi

    local history
    history=$(HISTTIMEFORMAT='' builtin history 1 | sed '1 s/^ *[0-9][0-9]*[* ] //')

    [ "$_last_history" = "$history" ] && return;

    local quoted_pwd=${PWD//\"/\\\"}

    # update cleanup_eternal_history if changed:
    local line="$USER"
    line="$line $(date +'%F %T')"
    line="$line $BASHPID"
    line="$line \"$quoted_pwd\""
    line="$line $history"
    printf "%s\n" "$line" >> "$_bashrc_eternal_history_file"

    _last_history=$history

    history -a
}

function __fzf_eternal_history__() {
  local line
  shopt -u nocaseglob nocasematch
  < "$_bashrc_eternal_history_file" FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS --tac --sync -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS +m" $(__fzfcmd) | cut -d' ' -f6-
}

##########
# Prompt #
##########

function _simple_prompt_command() {
  _add_to_history
}

_omb_util_add_prompt_command '_simple_prompt_command'

#######
# GPG #
#######
if command -v gpg2 > /dev/null ; then
  alias gpg=gpg2
else
  alias gpg2=gpg
fi

GPG_TTY="$(tty)"
export GPG_TTY

if pgrep gpg-agent > /dev/null 2>&1 ; then
  echo UPDATESTARTUPTTY | gpg-connect-agent > /dev/null 2>&1
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

#############
# Terraform #
#############
export CHECKPOINT_DISABLE=1

#######
# AWS #
#######
export SAM_CLI_TELEMETRY=0

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

if [[ -n "$DISPLAY" ]] ; then
  export VISUAL="gvim -v"
else
  export VISUAL=vim
fi

export FZF_DEFAULT_OPTS="--ansi --exact"
if command -v fd > /dev/null ; then
  export FZF_DEFAULT_COMMAND="fd --type file --color=always --hidden --exclude .git"
elif command -v fd-find > /dev/null ; then
  export FZF_DEFAULT_COMMAND="fd-find --type file --color=always --hidden --exclude .git"
fi
export SKIM_DEFAULT_COMMAND="$FZF_DEFAULT_COMMAND"

for file in "/usr/share/fzf/key-bindings.bash" "/opt/homebrew/opt/fzf/shell/key-bindings.bash" ; do
  if [[ -e "$file" ]] ; then
  # shellcheck disable=SC1090,SC1091
    source "$file"
    bind '"\eh": " \C-e\C-u\C-y\ey\C-u`__fzf_eternal_history__`\e\C-e\er\e^"'
  fi
done

if [ -e "/opt/homebrew/opt/fzf/shell/key-bindings.bash" ]  ; then
  # shellcheck disable=SC1090,SC1091
  . /opt/homebrew/opt/fzf/shell/completion.bash
fi

# Use fd (https://github.com/sharkdp/fd) instead of the default find
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
if command -v fd > /dev/null ; then
  _fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
  }
  # Use fd to generate the list for directory completion
  _fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
  }
elif command -v fd-find > /dev/null ; then
  _fzf_compgen_path() {
    fd-find --hidden --follow --exclude ".git" . "$1"
  }
  # Use fd to generate the list for directory completion
  _fzf_compgen_dir() {
    fd-find --type d --hidden --follow --exclude ".git" . "$1"
  }
fi


if uname -s | grep Darwin > /dev/null ; then
  RUST_SRC_PATH=/usr/local/share/rust/rust_src
else
  RUST_SRC_PATH="/usr/lib$(case "$(uname -m)" in x86_64) echo "64" ;; *) echo "" ;; esac; )/rustlib/src/rust/src"
fi

export RUST_SRC_PATH

export GTAGSLABEL=pygments

if command -v bat > /dev/null ; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
fi

if [ -e ~/.emacs.d/bin ] ; then
  PATH="$HOME/.emacs.d/bin:$PATH"
  export PATH
fi

export COLORTERM=truecolor

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

alias sshnokeys="ssh -o PreferredAuthentications=keyboard-interactive"
alias scpnokeys="scp -o PreferredAuthentications=keyboard-interactive"
alias sftpnokeys="sftp -o PreferredAuthentications=keyboard-interactive"

alias gogo="rlwrap -c telnet localhost 5356"

alias rubclean="rubber --clean"

alias touchpadon="synclient TouchpadOff=0"
alias touchpadoff="synclient TouchpadOff=1"

if [[ $(id -u) == "0" ]] ; then
  function sr() {
    if [[ $1 == install ]] || { [[ $1 == batch ]] && [[ $2 == install ]] ; } ; then
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

if uname -s | grep Darwin > /dev/null ; then
  alias emacs="emacs -nw" && alias emacsclient="emacs -nw -a '' -c"
else
  [[ -n "$DISPLAY" ]] && alias vim="gvim -v"
  [[ -n "$DISPLAY" ]] && alias emacs="emacs -nw" && alias emacsclient="emacsclient -nw -a '' -c"
  [[ -z "$DISPLAY" ]] && [[ -e /usr/bin ]] && alias emacs="$(basename "$(find /usr/bin/ -name 'emacs*-no-x11')") -nw" && alias emacsclient="$(basename "$(find /usr/bin/ -name 'emacs*-no-x11')") -nw -a '' -c"
fi

alias ansistrip="perl -e 'use Term::ANSIColor qw(colorstrip); print colorstrip \$_ while <>;'"

# ruby / rails
alias be='bundle exec'
alias bi='NOKOGIRI_USE_SYSTEM_LIBRARIES=1 bundle install'
alias rtdb='bundle exec rake db:environment:set db:drop db:create db:test:prepare db:environment:set RAILS_ENV=test'

# node

install_node_dev() {
  npm install -g import-js
}

# python
export PYRIGHT_PYTHON_IGNORE_WARNINGS=1

clean_python_caches() {
  find . -name '__pycache__' -exec rm -rf {} +
  find . -name '*.pyc' -exec rm -rf {} +
}

update_pyright() {
  if uname -s | grep Darwin > /dev/null ; then
    rm -rf /private/var/folders/cn/pfncnqhx063fvz8bnh532xw40000gq/T/pyright-*
  else
    rm -rf /tmp/pyright-*
  fi

  rm -rf ~/.emacs.d/.cache/lsp/npm/pyright/
}

# mac
if uname -s | grep Darwin > /dev/null ; then
  update_chromium() {
    brew reinstall chromium --no-quarantine --cask
  }
fi

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

  w3m -dump "http://time.is/$search" | sed -n '/[[:digit:]][[:digit:]]:[[:digit:]][[:digit:]]:[[:digit:]][[:digit:]]/p;/^Time in /p;/^Sun: /p' | sed 's/More info$//'
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
  if [ $# -ne 1 ] && [ $# -ne 2 ] ; then
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
  local pom
  pom="$(find_mvn_project "$@")"

  [ -n "$pom" ] || (>&2 echo "Project not found" && return 1)

  cd "$(dirname "$pom")" || return $?
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

function update_spacemacs_packages() {
  emacs --batch -l ~/.emacs.d/init.el --eval="(configuration-layer/update-packages t)"
}

function update_dotfiles() {
  (
    cd "$HOME/.dotfiles" || return $?
    git remote update --prune
    git pull --quiet
    git submodule --quiet update --init
    vim -u NONE -c "helptags ALL" -c q
  )
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

  if [ "$LAST" = "-" ] ; then
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

if uname -s | grep Darwin > /dev/null ; then
  export BASH_SILENCE_DEPRECATION_WARNING=1
  export CLICOLOR=YES

  eval "$(brew shellenv)"
  if [ -e "/opt/homebrew/opt/openjdk/bin" ] ; then
    export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
  elif [ -e "/opt/homebrew/opt/openjdk@17/bin" ] ; then
    export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
  fi

  if command -v rbenv > /dev/null ; then
    eval "$(rbenv init -)"
  fi

  if command -v pyenv > /dev/null ; then
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
  fi

  if [ -e "$HOME/.nvm" ] ; then
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
    # shellcheck disable=SC1091
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
  fi

  export HOMEBREW_NO_ANALYTICS=1
else
  if ! command -v tfenv > /dev/null ; then
    if [ -e "$HOME/.tfenv" ] ; then
      export PATH="$HOME/.tfenv/bin:$PATH"
    fi
  fi

  if [ -e "$HOME/.nvm" ] ; then
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  fi
fi

if command -v thefuck > /dev/null ; then
  # shellcheck disable=SC2046
  eval $(thefuck --alias)
fi

# if [ -s "$HOME/.gvm/scripts/gvm" ] ; then
#   # shellcheck disable=SC1091
#   source "$HOME/.gvm/scripts/gvm"
# fi

if [ -e "$HOME/.cargo/env" ] ; then
  # shellcheck disable=SC1090,SC1091
  source "$HOME/.cargo/env"
fi

if [ -e "$HOME/.sdkman/bin/sdkman-init.sh" ] ; then
  # shellcheck disable=SC1090,SC1091
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi
