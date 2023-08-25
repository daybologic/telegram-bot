#!/bin/sh

while true; do
	PERL5LIB=lib:externals/libdata-money-perl/lib:externals/libgeo-weather-visualcrossing-perl/lib bin/m6kvmdlcmdr.pl
	sleep 90
done

exit 0
