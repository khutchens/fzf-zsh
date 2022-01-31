autoload -Uz chpwd_recent_dirs cdr
autoload -U add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

zstyle ':chpwd:*' recent-dirs-max 32

if [[ ! -n $FZF_ZSH__FIND_CMD ]]; then
    FZF_ZSH__FIND_CMD='find .'
fi

function _fzf_zsh__list_parents() {
    while true
    do
        echo $PWD
        if [[ "$PWD" == "/" ]]
        then
            break
        else
            cd ..
        fi
    done
}

function fzf_zsh__cd() {
    local dir=$(${=FZF_ZSH__FIND_CMD} -type d 2> /dev/null | fzf +m)
    if [ $? -ne 0 ]; then
        return
    fi
    cd $dir
}

function fzf_zsh__cd_upward() {
    local dir=$(_fzf_zsh__list_parents | fzf +m)
    if [ $? -ne 0 ]; then
        return
    fi
    cd $dir
}

function fzf_zsh__cd_history() {
    local dir=$(cdr -l | awk '{print $2}' | fzf +m)
    if [ $? -ne 0 ]; then
        return
    fi
    cd $dir
}

function fzf_zsh__edit() {
    fzf +m --select-1 --exit-0 | xargs -o $EDITOR
}

function fzf_zsh__exec_history() {
    local cmd=$(fc -l -1000 | fzf -m +s --tac | sed 's/ *[0-9]* *//')
    if [ -n $cmd ]; then
        print -s $cmd
        eval $cmd
    fi
}

function fzf_zsh__kill() {
    $(ps -ef | sed 1d | fzf -m | awk "{print \$2}" | xargs kill -9)
}
