#!/bin/sh

while true; do
	PERL5LIB=lib:$HOME/workspace/libdata-money-perl/lib bin/m6kvmdlcmdr.pl
	sleep 90
done

exit 0
