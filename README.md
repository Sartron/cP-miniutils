# cP-miniutils
This repository stores general scripts for use with cPanel that don't really need their own standalone repository. The purpose of each script varies, and was usually only made for some problem I encountered.

# Projects
Below are the current projects stored in this repository.

## Partial Failure Backup Checker
`bash <(curl -s https://raw.githubusercontent.com/Sartron/cP-miniutils/master/partialfail.sh) file...`  
A script used to check for why a cPanel backup log returned partial failure.

## cPanel Backup Calculator
`bash <(curl -s https://raw.githubusercontent.com/Sartron/cP-miniutils/master/backupcalc.sh)`
A basic backup size calculator based on repquota output.