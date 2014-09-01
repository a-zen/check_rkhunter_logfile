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

## default warning and critical values
# -q
warnFileAgeMinutes="1440"
# -r
critFileAgeMinutes="1440"
# -s
warnSuspectFiles="1"
# -t
critSuspectFiles="1"
# -u
warnPossibleRootkits="1"
# -v
critPossibleRootkits="1"
# -w
warnSuspectApplications="1"
# -x
critSuspectApplications="1"
# -y
warnNumberOfWarnings="1"
# -z
critNumberOfWarnings="1"


# functions
function usage {
  echo "This script checks the output of a rkhunter logfile and alerts, if"
  echo "certain limits are overstepped. Critical thresholds are"
  echo "overtrumped by warning thresholds."
  echo ""
  echo "Usage: $SCRIPTNAME [-h] [-v] [-f rkhunter logfile]"
  echo "                   [ -qrstuvwxyz thresholds (see options)]"
  echo ""
  echo "Options:"
  echo "-h Print this help message"
  echo "-v Print version"
  echo "-f Sets path to rkhunter logfile (default: ${logFile})"
  echo "-q warning threshold for logfile age in minutes (default: ${warnFileAgeMinutes})"
  echo "-r critical threshold for logfile age in minutes (default: ${critFileAgeMinutes})"
  echo "-s warning threshold for number of suspected files (default: ${warnSuspectFiles})"
  echo "-t critical threshold for number of suspected files (default: ${critSuspectFiles})"
  echo "-u warning threshold for number of possible rootkits (default: ${warnPossibleRootkits})"
  echo "-v critical threshold for number of possible rootkits (default: ${critPossibleRootkits})"
  echo "-w warning threshold for number of suspected applications (default: ${warnSuspectApplications})"
  echo "-x critical threshold for number of suspected applications (default: ${critSuspectApplications})"
  echo "-y warning threshold for number of warnings found in logfile (default: ${warnNumberOfWarnings})"
  echo "-z critical threshold for number of warnings found in logfile (default: ${critNumberOfWarnings})"
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
if [[ ! -f "${logFile}" ]]; then
  echo "ERROR: logfile not found at: ${logFile}"
  echo ""
  usage $EXIT_ERROR
fi

# check if logfile can be read
if [[ ! -r "${logFile}" ]]; then
  echo "ERROR: logfile could not be read at: ${logFile}"
  echo ""
  usage $EXIT_ERROR
fi


# all fine, begin actual work

# get numbers of values
curSuspectFiles=`grep "Suspect files:" ${logFile} | awk '{print $NF}'`
curPossibleRootkits=`grep "Possible rootkits:" ${logFile} | awk '{print \
$NF}'`
curSuspectApplications=`grep "Suspect applications:" ${logFile} | awk \
'{print $NF}'`
curNumberOfWarnings=`grep "\[ Warning \]" ${logFile} | wc -l`

# check for criticals
critOldFile=`find ${logFile} -mmin +${critFileAgeMinutes}`
if [ ${critOldFile} ]; then
  echo "CRITICAL: logfile at ${logFile} is older than ${critFileAgeMinutes} \
minutes!"
  exit ${EXIT_CRITICAL}
fi

if [ "${curSuspectFiles}" -ge "${critSuspectFiles}" ]; then
  echo "CRITICAL: rkhunter found ${curSuspectFiles} suspected files!"
  exit ${EXIT_CRITICAL}
fi

if [ "${curPossibleRootkits}" -ge "${critPossibleRootkits}" ]; then
  echo "CRITICAL: rkhunter found ${curPossibleRootkits} possible rootkits!"
  exit ${EXIT_CRITICAL}
fi

if [ "${curSuspectApplications}" -ge "${critSuspectApplications}" ]; then
  echo "CRITICAL: rkhunter found ${curSuspectApplications} suspect \
applications!"
  exit ${EXIT_CRITICAL}
fi

if [ "${curNumberOfWarnings}" -ge "${critNumberOfWarnings}" ]; then
  echo "CRITICAL: rkhunter found ${curNumberOfWarnings} suspect \
applications!"
  exit ${EXIT_CRITICAL}
fi

# check for warnings
warnOldFile=`find ${logFile} -mmin +${warnFileAgeMinutes}`
if [ ${warnOldFile} ]; then
  echo "WARNING: logfile at ${logFile} is older than ${warnFileAgeMinutes} \
minutes!"
  exit ${EXIT_WARNING}
fi

if [ "${curSuspectFiles}" -ge "${warnSuspectFiles}" ]; then
  echo "WARNING: rkhunter found ${curSuspectFiles} suspected files!"
  exit ${EXIT_WARNING}
fi

if [ "${curPossibleRootkits}" -ge "${warnPossibleRootkits}" ]; then
  echo "WARNING: rkhunter found ${curPossibleRootkits} possible rootkits!"
  exit ${EXIT_WARNING}
fi

if [ "${curSuspectApplications}" -ge "${warnSuspectApplications}" ]; then
  echo "WARNING: rkhunter found ${curSuspectApplications} suspect \
applications!"
  exit ${EXIT_WARNING}
fi

if [ "${curNumberOfWarnings}" -ge "${warncritNumberOfWarnings}" ]; then
  echo "WARNING: rkhunter found ${curNumberOfWarnings} suspect \
applications!"
  exit ${EXIT_WARNING}
fi

exit ${EXIT_OK}
