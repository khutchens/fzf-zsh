autoload -Uz chpwd_recent_dirs cdr
autoload -U add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

zstyle ':chpwd:*' recent-dirs-max 32

function fzf_zsh__find_cmd() {
    ftype=${ftype:='f'}
    if (( $+commands[bfs] )); then
        ignorefile='.fzfignore'
        ignore=''
        if [[ -f $ignorefile ]]; then
            for line in $(cat $ignorefile); do
                ignore+=" -exclude -path $line"
            done
        fi
        eval "bfs -type $ftype -follow -maxdepth 12 $ignore 2>/dev/null"
    else
        eval "find ."
    fi
}

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
    local dir=$(ftype=d fzf_zsh__find_cmd | fzf +m --scheme=path)
    if [[ -n $dir ]]; then
        cd $dir
    fi
}

function fzf_zsh__cd_upward() {
    local dir=$(_fzf_zsh__list_parents | fzf +m)
    if [[ -n $dir ]]; then
        cd $dir
    fi
}

function fzf_zsh__cd_history() {
    local dir=$(cdr -l | awk '{print $2}' | fzf +m --scheme=path)
    if [[ -n $dir ]]; then
        cd $dir
    fi
}

function fzf_zsh__edit() {
    fzf_zsh__find_cmd | fzf -m --select-1 --exit-0 --scheme=path | xargs -o $EDITOR
}

function fzf_zsh__exec_history() {
    local cmd=$(fc -l -1000 | fzf +m +s --tac  --scheme=history | sed 's/ *[0-9]* *//')
    if [ -n $cmd ]; then
        print -s $cmd
        eval $cmd
    fi
}

function fzf_zsh__kill() {
    $(ps -ef | sed 1d | fzf -m | awk "{print \$2}" | xargs kill -9)
}
