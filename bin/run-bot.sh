#!/bin/sh

while true; do
	PERL5LIB=lib:$HOME/workspace/libdata-money-perl/lib:$HOME/workspace/libgeo-weather-visualcrossing-perl/lib bin/m6kvmdlcmdr.pl
	sleep 90
done

exit 0
