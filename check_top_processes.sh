#!/bin/bash
#title           :check_top_processes.sh
#description     :Script checks top processes memory consumption
#author		     :K0nicki
#version         :1.0   
#usage		     :bash check_top_processes.sh -n 3
#==============================================================================

declare -a processesArr=(mem cpu pid cmd)
PROCESSES_NUMBER=3

help_msg() {
        [[ -n $1 ]] && echo "ERROR: $1"
        echo "Script displays top ram processes
    Usage: $0 --number <int> [OPTIONS] value
        
    -n | --number           Number of monitored top processes                               
    "
    exit 3
}

# Argument parsing
if [ $# -eq 0 ]; then
    help_msg
else
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n | --number)
            PROCESSES_NUMBER=$2
            shift               # Shift argument
            shift               # Shift value
            ;;
            -h | --help)
            help_msg
            exit 0
            ;;
            *)
            help_msg
            exit 127
            ;;
        esac
    done
fi

# Read values
initializateProcessesArray() {
    for counter in $(seq 1 ${#processesArr[@]}); do
        processesArr[$(($counter - 1))]=$(ps -eo pmem,pcpu,pid,cmd | sort -k 1 -nr 2>/dev/null |head -n $PROCESSES_NUMBER |awk -F ' ' {"print \$$counter"})
    done
}

# Create table for pretty output
printUserOutput() {
    printf "%-5s %-5s %-7s %s\n" "PID" "CPU" "Memory" "Name"
    for counter in $(seq 1 $PROCESSES_NUMBER); do
        printf "%-5d %-6s %-5s %s\n" \
            $(echo ${processesArr[2]} | awk -F' ' {"printf \$$counter"}) \
            $(echo ${processesArr[1]} | awk -F' ' {"printf \$$counter"}) \
            $(echo ${processesArr[0]} | awk -F' ' {"printf \$$counter"}) \
            $(echo ${processesArr[3]} | awk -F' ' {"printf \$$counter"})
    done
}

# Output for Graphite
printGraphiteOutput() {
    printf "| "
    for counter in $(seq 1 $PROCESSES_NUMBER); do
        printf "$(echo ${processesArr[2]} |awk -F' ' {"printf \$$counter"})_$(echo ${processesArr[3]} | awk -F' ' {"printf \$$counter"}).mem=$(echo ${processesArr[0]} | awk -F' ' {"printf \$$counter"});;;; "
        printf "$(echo ${processesArr[2]} | awk -F' ' {"printf \$$counter"})_$(echo ${processesArr[3]} | awk -F' ' {"printf \$$counter"}).cpu=$(echo ${processesArr[1]} | awk -F' ' {"printf \$$counter"});;;; "
    done
}

initializateProcessesArray
printUserOutput
printGraphiteOutput

exit 0
