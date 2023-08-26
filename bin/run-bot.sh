#!/bin/sh

INSTALLED_ERROR=42 # arbitary

while true; do
	PERL5LIB=lib:externals/libdata-money-perl/lib:externals/libgeo-weather-visualcrossing-perl/lib bin/m6kvmdlcmdr.pl
	exitCode=$?
	if [ $exitCode -eq $INSTALLED_ERROR ]; then
		echo "ERROR: Installation/setup error detected; aborted"
		break;
	fi
	sleep 90
done

exit 0
