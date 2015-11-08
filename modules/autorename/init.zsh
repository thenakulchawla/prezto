#
# Autorenames terminal/tmux window title.
#

[[ -n "$TITLE_OVERFLOW_SIZE" ]] || TITLE_OVERFLOW_SIZE=13

function autorename_pwd {
    local pwd="${PWD/#$HOME/~}"

    if [[ "$pwd" == (#m)[/~] ]]; then
        _autorename_pwd="$MATCH"
        unset MATCH
    else
        _autorename_pwd="${${${${(@j:/:M)${(@s:/:)pwd}##.#?}:h}%/}//\%/%%}/${${pwd:t}//\%/%%}"
    fi
}

function precmd_title {
    local size=${1:=$TITLE_OVERFLOW_SIZE}
    autorename_pwd
    _precmd_title=$_autorename_pwd
    if [ ${#_precmd_title} -gt $size ]; then
        _precmd_title="..${${_precmd_title:t:r}[-$size,-1]}"
    fi
}

function preexec_title {
    local size=${2:=$TITLE_OVERFLOW_SIZE}
    local cmd
    local args
    _preexec_title=$1
    if [ ${#_preexec_title} -gt $size ]; then
        cmd=${1%% *}
        args=${1#* }
        _preexec_title="$cmd ..${${args}[-$size+$#_cmd,-1]}"
    fi
}

function settitle {
    case $TERM in
        termite|*xterm*|rxvt|rxvt-unicode|rxvt-256color|rxvt-unicode-256color|(dt|k|E)term)
            if [ $TMUX ]; then
                print -Pn "\033k$1\033\\"
            else
                print -Pn "\e]0;$1\a"
            fi
            ;;

        screen|screen-256color)
            precmd () {
                print -Pn "\e]83;title \"$1\"\a"
                print -Pn "\e]0;$TERM - (%L) %n@%M: %~\a"
            }
            preexec () {
                print -Pn "\e]83;title \"$1\"\a"
                print -Pn "\e]0;$TERM - (%L) %n@%M: %~ ($1)\a"
            }
            ;;
    esac
}

case $TERM in
    termite|*xterm*|rxvt|rxvt-unicode|rxvt-256color|rxvt-unicode-256color|(dt|k|E)term)
        if [ $TMUX ]; then
            precmd () {
                precmd_title
                print -Pn "\033k$_precmd_title\033\\"
            }
            preexec () {
                preexec_title "$1"
                print -Pn "\033k$_preexec_title\033\\"
            }
        else
            precmd () {
                precmd_title 25
                print -Pn "\e]0;${SSH_CONNECTION:+%M: }$_precmd_title\a"
            }
            preexec () {
                preexec_title "$1" 25
                print -Pn "\e]0;${SSH_CONNECTION:+%M: }$_preexec_title\a"
            }
        fi
        ;;

    screen|screen-256color)
        precmd () {
            print -Pn "\e]83;title \"$1\"\a"
            print -Pn "\e]0;$TERM - (%L) %n@%M: %~\a"
        }
        preexec () {
            print -Pn "\e]83;title \"$1\"\a"
            print -Pn "\e]0;$TERM - (%L) %n@%M: %~ ($1)\a"
        }
        ;;
esac
