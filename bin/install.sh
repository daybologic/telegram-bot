#!/bin/sh

set -e

INSTALLED_ERROR=42 # arbitary

if [ `id -u` -ne 0 ]; then
	>&2 echo "ERROR: Installation script must be run as the super-user";
	exit $INSTALLED_ERROR;
fi

CACHEDIR='/var/cache/telegram-bot'
mkdir -p "$CACHEDIR"
chmod 0700 "$CACHEDIR"

# FIXME: Need a UID for the bot
chown palmer "$CACHEDIR"

# TODO: The following will only work on Debian; need to bang out
# on other operating systems.
sudo apt install \
	libconfig-ini-perl \
	libdatetime-perl \
	libdbd-mysql-perl \
	libdbi-perl \
	libjson-maybexs-perl \
	libtime-duration-perl \
	libmoose-perl \
	libuniversal-require-perl \
	liburi-encode-perl \
	libwww-perl \
	perl \
	perl-base \
	perl-modules-5.32

exit 0
