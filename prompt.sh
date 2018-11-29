#!/bin/bash

OFF=0
BOLD=1
UNDERSCORE=4
BLINK=5
REVERSE=7
CONCEALED=8

FG=3
BG=4
BLACK=0
RED=1
GREEN=2
YELLOW=3
BLUE=4
MAGENTA=5
CYAN=6
WHITE=7


function mpt_handle_tmux
{
    if [ -z $TMUX ] ; then
        return
    fi

    $(tmux set-option status-left-length ${#tmuxl})
    $(tmux set-option status-left "$tmuxl")
}

function mpt_tmux_add
{
    tmuxl="${tmuxl}#[bg=$1]$2"
}

function mpt_tmux_part
{
    mpt_tmux_add $1 "[$2]"
}

function mpt_add
{
    prompt="${prompt}$1"
}

function mpt_chclr
{
    mpt_add "\033[${1}m"
}

function mpt_sepa
{
    mpt_chclr "$OFF;$FG$CYAN"
    mpt_add   $1
    mpt_chclr "$OFF"
}

function mpt_add_part
{
    mpt_sepa "["
    mpt_add  "$1"
    mpt_sepa "]"
}

#Don't forget to call HOSTBASED before this
function mpt_add_cwd
{
    mpt_sepa "["
    
    local U="$USER"
    if [ ! -z $SUDO_UID ] ; then
        mpt_chclr  "$BOLD;$BG$RED"
        local U="root"
    fi
    if [ $USER == "root" ] ; then
        mpt_chclr  "$BOLD;$BG$RED"
    fi
    mpt_add  "$U"

    mpt_sepa "@"
    eval mpt_chclr $PROMPT_HOSTCOLOR 
    mpt_add  "$HOSTNAME"
    mpt_chclr "$OFF"
    mpt_sepa  ":"
    mpt_add   "$PWD"
    mpt_sepa "]"
}

function mpt_handle_netns
{
    if [ -z $IPNETNS ] ; then
        return
    fi
    mpt_sepa "{"
    mpt_chclr "$OFF;$FG$YELLOW"
    mpt_add "$IPNETNS"
    mpt_chclr "$OFF"
    mpt_sepa "}"
}

function mpt_handle_aws
{
    if [ -z $AWS_PROFILE ] ; then
        return
    fi
    mpt_sepa "["
    mpt_add  "$AWS_PROFILE"
    mpt_sepa "]"
}

function mpt_handle_git
{
    #Handle git
    gitstring="`GIT_PS1_SHOWDIRTYSTATE=1 GIT_PS1_SHOWSTASHSTATE=1 GIT_PS1_SHOWUNTRACKEDFILES=1 GIT_PS1_SHOWUPSTREAM= __git_ps1 \"%s\"`"
    if [ "${gitstring}" != "" ] ; then
        mpt_sepa "|"
        mpt_add "${gitstring}"
        mpt_sepa "|"
    fi
}

function MagicPrompt
{
    old_ret=$?
    prompt=""
    tmuxl=""
    mpt_add_part "$(date +%H:%M:%S)"
    mpt_add_part "$old_ret"
    mpt_add_cwd
    mpt_handle_aws
    mpt_handle_netns
    mpt_handle_git
    #Handle extenders :)
    for i in $(set | grep "^mpt_extra_" | sed 's/()//g') ; do
        $i
    done

    echo -e $prompt

    mpt_handle_tmux

}


export PROMPT_COMMAND_SAVE=$PROMPT_COMMAND
export PS1_SAVE=$PS1
PROMPT_COMMAND=MagicPrompt
PS1=""
