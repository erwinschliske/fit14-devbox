#! /bin/bash

# ====================================================================================================

TIMEFORMAT=%R
export LANG=C

declare -i failed=0

# ====================================================================================================

sCurrentDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! "$sCurrentDir" = "/vagrant/setup" ]; then
	echo "Use '/vagrant/setup/check_internal.sh' in your VM to execute this script\n"
	echo "or run 'vagrant ssh -c /vagrant/setup/check_internal.sh'."
	exit 1
fi

# ====================================================================================================

source "$sCurrentDir/functions.sh"

# ====================================================================================================

sTemp=$( { time host 'example.com' > /dev/null; } 2>&1 )

iTime=`echo $sTemp | cut -d " " -f 2`
iTime=$(echo "$iTime 1000" | awk '{printf "%.0f \n", $1*$2}')

sMessage="DNS lookup speed"
if [ "$iTime" -lt 2000 ]; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================

sMessage="File '/etc/dhcp/dhclient.d/resolvconf.sh' does not exist"
if [ ! -f "/etc/dhcp/dhclient.d/resolvconf.sh" ]; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================

sMessage="File '/etc/yum.repos.d/fit-devel14.repo' exists"
if [ -f "/etc/yum.repos.d/fit-devel14.repo" ]; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================

iCheck=`yum repolist enabled --disablerepo=* --enablerepo=fit14 -c /etc/yum.repos.d/ | grep -c 'fit14'`

sMessage="YUM repository 'fit14' is enabled"
if [ "$iCheck" -gt 0 ]; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================

sMessage="File '/etc/motd' exists"
if [ -f "/etc/motd" ]; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi


# ====================================================================================================

aTools=(bash-completion libtool-ltdl vim wget git nc bind-utils traceroute tcpdump acpid strace)

sOutput=`yum list installed`

for sTool in "${aTools[@]}"
do
	iCheck=`echo $sOutput | grep -c $sTool`

	sMessage="Check package '$sTool'"
	if [ "$iCheck" -gt 0 ]; then
		_printLine "$sMessage" 1
	else
		_printLine "$sMessage" 0
	fi
done

# ====================================================================================================

aCertFiles=(crt csr key)

for sCertFile in "${aCertFiles[@]}"
do
	sMessage="SSL-File 'local14.sevenval-fit.com.$sCertFile' exists"
	if [ -f "/opt/sevenval/fit14/conf/ssl/local14.sevenval-fit.com.$sCertFile" ]; then
		_printLine "$sMessage" 1
	else
		_printLine "$sMessage" 0
	fi
done

# ====================================================================================================

aConfFiles=("domains.xml" "fpm.d/fpmlimits.conf" "include.global/limits.conf" "fit.ini.d/devel.ini")

for sConfFile in "${aConfFiles[@]}"
do
	sMessage="Config file '$sConfFile' exists"
	if [ -f "/opt/sevenval/fit14/conf/$sConfFile" ]; then
		_printLine "$sMessage" 1
	else
		_printLine "$sMessage" 0
	fi

	sMessage="Owner of '$sConfFile' is 'fit/fit-data'"
	if [ `stat -c "%U:%G" /opt/sevenval/fit14/conf/$sConfFile` = "fit:fit-data" ]; then
		_printLine "$sMessage" 1
	else
		_printLine "$sMessage" 0
	fi

	sMessage="Permissions of '$sConfFile'"
	if [ `stat -c "%a" /opt/sevenval/fit14/conf/$sConfFile` = "640" ]; then
		_printLine "$sMessage" 1
	else
		_printLine "$sMessage" 0
	fi
done

# ====================================================================================================

iCheck=`ls /opt/sevenval/fit14/conf/vhosts/ | grep -c 'local14.sevenval-fit.com.conf'`

sMessage="VHosts have been configured"
if [ "$iCheck" -gt 0 ]; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================

sCheck=`sudo /opt/sevenval/fit14/bin/fitadmin extension list -s`

sMessage="CDR-Extension installed"
if [ "$sCheck" = "cdr" ]; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================

sMessage="fpmstatus.conf exists"
if [ -f "/opt/sevenval/fit14/conf/fpm.d/fpmstatus.conf" ]; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================


sMessage="PHP-FPM is running"
if sudo /opt/sevenval/fit14/sbin/phpfpmctl status 2>&1 > /dev/null; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================


sMessage="Apache is running"
if sudo /opt/sevenval/fit14/sbin/apachectl status 2>&1 > /dev/null; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================

sMessage="File '/etc/profile.d/fit14.sh' exists"
if [ -f "/etc/profile.d/fit14.sh" ]; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================

sCheckBIN=`which fitadmin`
sCheckSBIN=`which phpfpmctl`

sMessage="PATH is valid"
if [ "$sCheckBIN" = "/opt/sevenval/fit14/bin/fitadmin" -a "$sCheckSBIN" = "/opt/sevenval/fit14/sbin/phpfpmctl" ]; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================

sMessage="PATH is writen into '/etc/profile.d/fit14.sh'"
if grep -q "export PATH=/opt/sevenval/fit14/bin/:/opt/sevenval/fit14/sbin/:" "/etc/profile.d/fit14.sh"; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================

sMessage="Alias 'vi=vim' is writen into '/etc/profile.d/fit14.sh'"
if grep -q "alias vi=vim" "/etc/profile.d/fit14.sh"; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================

iCheck=`/opt/sevenval/fit14/lib/fit/bin/curl -s 'http://192.168.56.14:8080/test.fit' | grep -c 'Overall: alive'`

sMessage="Config check (calling /test.fit per IP and HTTP)"
if [ "$iCheck" -gt 0 ]; then
	_printLine "$sMessage" 1
else
	_printLine "$sMessage" 0
fi

# ====================================================================================================

EXP_VERSION="14-0-0"
FIT_VERSION=`fitadmin -v | head -n1`

sMessage="FIT Version '$EXP_VERSION' (is: $FIT_VERSION)"

echo "$FIT_VERSION" | grep -q "Sevenval FIT Server $EXP_VERSION, Build:" && \
	_printLine "$sMessage" 1 || _printLine "$sMessage" 0

# ====================================================================================================

exit $failed
