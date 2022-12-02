# colors for prompt
blue="\[\e[0;36m\]"
purple="\[\e[1;35m\]"
green="\[\e[3;32m\]"
fgreen="\001\e[3;32m\002"
bgreen="\001\e[42m\002"
red="\[\e[3;91m\]"
fred="\001\e[3;91m\002"
bred="\001\e[41m\002"
yellow="\[\e[3;33m\]"
default="\[\e[0m\]"
clr="\001\033[00\002"

# prompt
export PS1="\n${blue}[${purple}\w${blue}]\n[${red}\u${blue} @ ${red}\h${blue}]\$(show_exit_status \$?)${default}${yellow}\$(parse_git_branch) $ ${default}"

# enable timestamps in history
export HISTTIMEFORMAT="%F %T "

# set vi editing mode
set -o vi

# aliases
alias ls='ls --color=auto -F'
alias l='ls --color=auto -F'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias lt='ls --color=auto -lrt'
alias ll='ls --color=auto -l'
alias la='ls --color=auto -al'
alias tf='tail -fn 1000'
alias grep='grep --color=auto'

alias dte='date +"%a, %d %b %Y %H:%M:%S %z"'
alias galias='git config --list | grep alias'
alias showlog='tail -fn 1000 /var/log/syslog'
alias usage='du -hsx * | sort -rh | tail -20'

alias rcp='~/tools/remote-copy'
alias rk='~/tools/replace-keys'
alias rr='~/tools/remote-run'

# used to build packages on different dists
build_pkg()
{
    # usage check
    if [[ $# -lt 1 || $# -gt 2 ]]; then
        echo "Usage: build_pkg focal|xenial [-n|--native]" 1>&2
        return
    fi

    # set distribution
    if [[ $1 = "focal" ]]; then
        _DIST_="focal-stage4"
    elif [[ $1 = "xenial" ]]; then
        _DIST_="xenial-stage4"
    else
        echo "Error: unrecognized distribution..." 1>&2
    fi

    # update cowbuilder chroot
    sudo HOME=$HOME DIST=${_DIST_} cowbuilder --update

    # build the package
    if [[ $# = 1 ]]; then
        DIST=${_DIST_} debmake -y -t --invoke 'pdebuild --pbuilder cowbuilder -- --debbuildopts=-b'
    elif [[ $# = 2 && ( $2 = "-n" || $2 = "--native" ) ]]; then
        DIST=${_DIST_} debmake -y -n --invoke 'pdebuild --pbuilder cowbuilder -- --debbuildopts=-b'
    else
        echo "Error: unrecognized argument: ${2}" 1>&2
        return
    fi
}

# used to navigate to the appropriate build dir
build_dir()
{
    # usage check
    if [[ $# -ne 1 ]]; then
        echo "Usage: build_dir focal|xenial" 1>&2
        return
    fi

    # switch directories
    if [[ $1 != "focal" && $1 != "xenial" ]]; then
        echo "Error: expecting either 'focal' or 'xenial' distributions" 1>&2
        return
    fi

    cd /var/cache/pbuilder/${1}-stage4-amd64/result/
}

##### Functions for my prompt #####

# show git branch currently on
parse_git_branch()
{
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# change color of prompt based on last command exit status
show_exit_status()
{
    [[ $1 == "0" ]] && printf -- "$fgreen ^_^" || printf -- "$fred o_0";
}


# mc related
if [ -f /usr/lib/mc/mc.sh ]; then
    . /usr/lib/mc/mc.sh
fi
