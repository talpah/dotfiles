export PATH=$HOME/bin:$PATH
export DISPLAY=:0.0

export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;31'
export EDITOR='vim'

export HISTCONTROL=erasedups  # Ignore duplicate entries in history
export HISTSIZE=10000         # Increases size of history
export HISTIGNORE="&:ls:ll:la:l.:pwd:exit:clear:clr:[bf]g"
shopt -s histappend        # Append history instead of overwriting
shopt -s cdspell           # Correct minor spelling errors in cd command
shopt -s dotglob           # includes dotfiles in pathname expansion
shopt -s checkwinsize      # If window size changes, redraw contents
shopt -s cmdhist           # Multiline commands are a single command in history.
shopt -s extglob           # Allows basic regexps in bash.

# ALAISES

# Linux Specific
export LS_COLORS="di=34;40:ln=35;40:so=32;40:pi=33;40:ex=31;40:bd=34;46:cd=34;43:su=0;41:sg=0;46:tw=0;42:ow=0;43:"
export EDITOR='vim'

alias agi="sudo apt-get install"
alias acs="sudo apt-cache search"
alias acsh="sudo apt-cache show"
alias aguu="sudo apt-get update && sudo apt-get upgrade"
alias ls="ls -F --color"       # Color is handled differently on Linux

# Configs that rely on stuff in the case statement
export VISUAL=$EDITOR
export SVN_EDITOR=$VISUAL
export GIT_EDITOR=$VISUAL

# Global
# Helpers
alias grep='grep --color=auto' # Always highlight grep search term
alias ping='ping -c 5'      # Pings with 5 packets, not unlimited
alias df='df -h'            # Disk free, in gigabytes, not bytes
alias du='du -h -c'         # Calculate total disk usage for a folder

# Nifty extras
alias servethis="python -c 'import SimpleHTTPServer; SimpleHTTPServer.test()'"
alias clr='clear;echo "Currently logged in on $(tty), as $(whoami) in directory $(pwd)."'
alias pypath='python -c "import sys; print sys.path" | tr "," "\n" | grep -v "egg"'
alias pycclean='find . -name "*.pyc" -exec rm {} \;'

## PROMPT
# Prompt Colors
BGREEN='\[\033[1;32m\]'
GREEN='\[\033[0;32m\]'
BRED='\[\033[1;31m\]'
RED='\[\033[0;31m\]'
BBLUE='\[\033[1;34m\]'
BLUE='\[\033[0;34m\]'
CYAN='\[\033[0;36m\]'
NORMAL='\[\033[00m\]'

parse_git_branch(){ git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'; }
get_virtualenv(){ if [ -n "$VIRTUAL_ENV" ]; then echo "(`basename \"$VIRTUAL_ENV\"`)"; fi }

# Prompt
PS1="\n${CYAN}(${NORMAL}\w${CYAN})${GREEN} \$(parse_git_branch)${RED}\$(get_virtualenv) \n${NORMAL}\u${CYAN}@\H${RED}\$ ${NORMAL}"

source $HOME/bin/virtualenvwrapper_bashrc

has_virtualenv() {
    if [ -e .venv ]; then
        workon `cat .venv`
    fi
}
venv_cd () {
    cd "$@" && has_virtualenv
}
alias cd="venv_cd"
