check_rkhunter_logfile
======================

# Description
This nagios script parses a rkhunter logfile and alarms according to given
boundaries. Rather than calling rkhunter directly like other nagios
scripts, this just parses the logfile of a already ran rkhunter (e.g. via
cron)

