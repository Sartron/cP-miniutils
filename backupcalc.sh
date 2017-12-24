#!/bin/bash

# cPanel Backup Calculator
# Calculates size of an uncompressed backup based on repquota. Not entirely accurate.

readonly UPDATED='December 24 2017';
readonly VERSION='1.00';

function Main()
{
	local quota_report=$(repquota -a);
	local cP_users=$(find /var/cpanel/users -type f \( ! -user nobody -and ! -group nobody -and ! -group root \) -exec basename '{}' \; | sort);
	local backup_enabled;
	
	# Exit if no cPanel users were found.
	[ -z "${cP_users}" ] && { echo 'No cPanel users were found.'; return 0; };
	
	
	# Get backup type.
	[ -f /etc/cpbackup.conf ] && grep '^BACKUPENABLE' /etc/cpbackup.conf | grep -q 'yes' && backup_enabled='Legacy';
	[ -f /var/cpanel/backups/config ] && grep '^BACKUPENABLE:' /var/cpanel/backups/config | grep -q 'yes' && backup_enabled='Modern';
	
	local total;
	
	for user in ${cP_users};
	do
		local enabled;
		
		# Check if backups are enabled for the user.
		[ "${backup_enabled}" == 'Legacy' ] && { grep -q '^LEGACY_BACKUP=1' "/var/cpanel/users/${user}" && enabled='0' || enabled='1'; };
		[ "${backup_enabled}" == 'Modern' ] && { grep -q '^BACKUP=1' "/var/cpanel/users/${user}" && enabled='0' || enabled='1'; };
		
		local user_usage=$(grep "${user}" <<< "${quota_report}" | awk '{print $3}');
		
		# Output usage and backup status.
		[ "${enabled}" == '1' ] && echo -n '[Disabled]' || echo -n '[Enabled]';
		echo " User '${user}' is using: ${user_usage} kB";
		
		(( total += ${user_usage} ));
	done
	
	# Output total backup size.
	echo "Total Usage: ${total} kB / $(( total / 1024 )) MB";
}

Main "${@}";