#/bin/bash

# Based on: https://github.com/tlatsas/bash-spinner

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

    local ON_SUCCESS="${GREEN}DONE${NOCOLOUR}"
    local ON_FAIL="${RED}FAIL${NOCOLOUR}"

    _spinner_kill

    # inform the user uppon success or failure
    echo -en "\b["
    if [ ${1:-0} -eq 0 ]; then
        echo -en $ON_SUCCESS
    else
        echo -en $ON_FAIL
    fi
    echo -e "]"

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

            # $2 : command exit status
            _spinner_stop $2

            unset _SPINNER_PID

        ;;

        *)
            echo "Invalid argument, try {start/stop}"
            exit 1
        ;;

    esac

}
