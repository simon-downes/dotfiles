#/bin/bash

# Based on: https://github.com/tlatsas/bash-spinner

# set some pretty colours if they're not already defined
RED=${RED-$(tput setaf 1)}
GREEN=${GREEN-$(tput setaf 2)}
YELLOW=${YELLOW-$(tput setaf 3)}
CYAN=${CYAN-$(tput setaf 6)}
NOCOLOUR=${NOCOLOUR-$(tput sgr0)}

function _spinner_start {

    _spinner_kill

    local FRAME_INDEX=1
    local FRAMES="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local DELAY=0.15

    echo -ne "${1}  " # Status message

    while true
    do
        printf "\b${GREEN}${FRAMES:FRAME_INDEX++%${#FRAMES}:1}${NOCOLOUR}"
        sleep $DELAY
    done

}

function _spinner_stop {

    # $1: integer exit code or string status message
    # $2: optional information message
    local RESULT=${1:-0}
    local INFO=${2:+" - ${CYAN}${2}${NOCOLOUR}"}

    local ON_SUCCESS="${GREEN}DONE${NOCOLOUR}"
    local ON_FAIL="${RED}FAIL${NOCOLOUR}"

    _spinner_kill

    # if RESULT is a number then it's an exit code so set an appropriate RESULT message
    if [ "${RESULT}" -eq "${RESULT}" ] 2> /dev/null; then

        if [ $RESULT -eq 0 ]; then
            RESULT=$ON_SUCCESS
        else
            RESULT=$ON_FAIL
        fi

    fi

    # output result status and info message
    echo -e "\b[${RESULT}]${INFO}"

}

function _spinner_kill {

    kill $_SPINNER_PID > /dev/null 2>&1

}

function spinner {

    case $1 in
        start)

            # $2 : msg to display
            { _spinner_start "${2}" & } 2>/dev/null

            # set global spinner pid
            _SPINNER_PID=$!

            # remove the background job from job control
            disown

            # make sure the spinner dies once the current process exits
            trap "kill -9 ${_SPINNER_PID} > /dev/null 2>&1" EXIT

        ;;

        stop)

            # $2 : command exit code or status message
            # $3 : information message
            _spinner_stop "$2" "$3"

            unset _SPINNER_PID

        ;;

        *)
            echo "Invalid argument, try {start/stop}"
            exit 1
        ;;

    esac

}

function spin {

    # $1: the message to display before the spinner
    # $2: the command to run
    # $3: the file that the command' stdout and stderr are directed to

    local MSG=$1
    local CMD=$2
    local LOG=${3:-"/dev/null"}

    spinner start "$MSG"
    $($CMD >> ${LOG} 2>&1)
    spinner stop $?

}
