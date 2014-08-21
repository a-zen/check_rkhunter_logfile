#!/bin/bash

# Script:   check_rkhunter_logfile.sh
# Purpose:  checks the logfile of rkhunter for warnings
# Author:   Alexander Zenger, github (at) zengers (dot) de
# License:  GPLv2, see LICENSE file

SCRIPTNAME=$(basename $0 .sh)
# nagios success
EXIT_SUCCESS=0
EXIT_OK=$EXIT_SUCCESS
# nagios warning
EXIT_FAILURE=1
EXIT_WARNING=$EXIT_FAILURE
# nagios critical
EXIT_ERROR=2
EXIT_CRITICAL=$EXIT_ERROR
# nagios unknown
EXIT_BUG=3
EXIT_UNKNOWN=$EXIT_BUG

VERSION=0.1

# Variables
#  -f
logFile="/var/log/rkhunter.log"
# -m

warnFileAgeMinutes="1440"
critFileAgeMinutes="1440"

warnSuspectFiles="1"
critSuspectFiles="1"

warnPossibleRootkits="1"
critPossibleRootkits="1"

warnSuspectApplications="1"
critSuspectApplications="1"

warnNumberOfWarnings="1"
critNumberOfWarnings="1"

# functions
function usage {
 echo "This script checks the output ..."
 echo ""
 echo "Usage: $SCRIPTNAME [-h] [-v] [-w warning threshold] [-c critical threshold]"
 echo "                   [ FIXME ]"
 echo ""
 echo "Options:"
 echo "-h Print this help message"
 echo "-v Print version"
 echo "-f Sets path to rkhunter logfile (default: ${logFile}"
 echo "-m Sets path to rkhunter logfile (default: ${logFile}"
 echo "-w Sets warning threshold (default: 10)"
 echo "-c Sets critical threshold (default: 60)"
 [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}

# Die Option -h fuer Hilfe sollte immer vorhanden sein, die Optionen
# -v und -o sind als Beispiele gedacht. -o hat ein Optionsargument;
# man beachte das auf "o" folgende ":".
while getopts 'f:m:vh' OPTION ; do
  case $OPTION in
  f) logFile="$OPTARG"
  ;;
  m) warFileAgeMinutes="$OPTARG"
  ;;
  w) warning="$OPTARG"
  ;;
  c) critical="$OPTARG"
  ;;
  h) usage $EXIT_SUCCESS
  ;;
  v) echo "Version: $VERSION"
     exit $EXIT_SUCCESS
  ;;
  \?) echo "Unknown option \"-$OPTARG\"." >&2
  usage $EXIT_ERROR
  ;;
  :) echo "Option \"-$OPTARG\" requires a argument." >&2
  usage $EXIT_ERROR
  ;;
  *) echo "This shouldn't happen...BUG" >&2
  usage $EXIT_BUG
  ;;
  esac
done

# check if logfile exists
if [[ -f "${logfile}" ]]; then
  echo "ERROR: logfile not found at: ${logFile}"
  usage $EXIT_ERROR
fi


# all fine, begin actual work

# grep "Suspect files:" rkhunter.log | awk '{print $NF}'
# grep "Possible rootkits:" rkhunter.log | awk '{print $NF}'
# grep "Suspect applications:" rkhunter.log | awk '{print $NF}'
# find rkhunter.log -mmin +1440
# grep "\[ Warning \]" rkhunter.log | wc -l


