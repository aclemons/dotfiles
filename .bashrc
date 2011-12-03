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
export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=384m"

#########
# Paths #
#########

export PATH=~/bin:$PATH

#############
# Init Vars #
#############

# bool to track first invocation for history
_first_invoke=1

###########
# Aliases #
###########

# prompt when overwriting with cp / mv
alias cp="cp -i"
alias mv="mv -i"

# case insensitive search in less
alias less="less -i"

alias sshnoauth="ssh -o PreferredAuthentications=keyboard-interactive"
alias scpnoauth="scp -o PreferredAuthentications=keyboard-interactive"

##################
# Misc Functions #
##################

function manifest() {
  local arg=$1

  unzip -c "$arg" META-INF/MANIFEST.MF | perl -0pe 's/\r?\n //sg' | perl -pi -e 's/\r\n/\n/g'
}
export -f manifest

# translate a word
function tl() {
   w3m -dump "http://dict.leo.org/ende?lang=de&search=$@" \
        | perl -ne 'print "$1\n" if /^\s*\│(.+)\│\s*$/' \
        | tac;
}
