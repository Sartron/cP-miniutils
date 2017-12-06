#!/bin/bash

# cPanel Partial Failure Backup Detection
# Skims through a cPanel backup log for the reason why a partial failure occurred.

readonly UPDATED='December 6 2017';
readonly VERSION='1.00';

function Main()
{
	# Ensure something was actually passed to the script.
	[ "${#@}" == '0' ] && { echo 'No arguments passed to script.'; return 1; };
	
	# Ensure that the backup script exists.
	[ ! -f /usr/local/cpanel/bin/backup ] && { echo 'cPanel backup script ''/usr/local/cpanel/bin/backup'' does not exist.'; return 1; };
	
	# Get failure reasons from /usr/local/cpanel/bin/backup.
	local failreason_list=$(awk '/sub parse_log_and_aggregate_errors {/,/^}/' /usr/local/cpanel/bin/backup | grep -Eo '\(m\/.+\/\)' | sed 's,\((m/\|/)\),,g');
	
	# Ensure that failure reasons returned something.
	[ -z "${failreason_list}" ] && { echo 'Unable to extract failure reasons from ''/usr/local/cpanel/bin/backup''.'; return 1; };
	
	# Loop through all arguments passed to the script.
	for file in "${@}";
	do
		# Check to see if the file actually exists. Skip it if it does not.
		[ ! -f "${file}" ] && { echo "File '${file}' does not exist."; continue; };
		
		# Loop through the list of reasons compiled earlier on the current file.
		echo "${file}";
		while read failreason;
		do
			grep -n "${failreason}" "${file}";
		done <<< "${failreason_list}";
		
		echo;
	done
	
	return 0;
}

Main "${@}";