#!/bin/bash

# cPanel Backup Calculator
# Calculates size of an uncompressed backup based on repquota. Not entirely accurate.

readonly UPDATED='December 29 2017';
readonly VERSION='1.03';

function Main()
{
	# Make sure the root user is being used.
	[ ${EUID} != '0' ] && { echo 'This script must be used as root.'; return 1; };
	
	local quota_report=$(repquota -a);
	local cP_users=$(find /var/cpanel/users -type f \( ! -user nobody -and ! -group nobody -and ! -group root \) -exec basename '{}' \; | sort);
	local backup_system;
	
	# Exit if no cPanel users were found.
	[ -z "${cP_users}" ] && { echo 'No cPanel users were found.'; return 0; };
	
	
	# Get backup type.
	[ -f /etc/cpbackup.conf ] && grep '^BACKUPENABLE' /etc/cpbackup.conf | grep -q 'yes' && backup_system='Legacy';
	[ -f /var/cpanel/backups/config ] && grep '^BACKUPENABLE:' /var/cpanel/backups/config | grep -q 'yes' && backup_system='Modern';
	
	local total;
	
	for user in ${cP_users};
	do
		# By default, the user is disabled in backups until proven otherwise.
		local enabled='0';
		
		# Check if backups are enabled for the user depending on what backup system is enabled.
		[ "${backup_system}" == 'Legacy' ] && { grep -q '^LEGACY_BACKUP=1' "/var/cpanel/users/${user}" && enabled='1' || enabled='0'; };
		[ "${backup_system}" == 'Modern' ] && { grep -q '^BACKUP=1' "/var/cpanel/users/${user}" && enabled='1' || enabled='0'; };
		
		local user_usage=$(grep -E "^${user}\s" <<< "${quota_report}" | awk '{print $3}');
		
		# Output usage and backup status.
		[ "${enabled}" == '1' ] && echo -n '[Enabled]' || echo -n '[Disabled]';
		echo " User '${user}' is using: ${user_usage} kB / $(( user_usage / 1024 )) MB";
		
		(( total += ${user_usage} ));
	done
	
	# Output total backup size.
	echo "Total Usage: ${total} kB / $(( total / 1024 )) MB";
}

Main "${@}";