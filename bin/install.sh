#!/bin/sh

set -e

INSTALLED_ERROR=42 # arbitary

if [ `id -u` -ne 0 ]; then
	>&2 echo "ERROR: Installation script must be run as the super-user";
	exit $INSTALLED_ERROR;
fi

CACHEDIR='/var/cache/telegram-bot'
LOGDIR='/var/log/telegram-bot'
DBDIR='/var/lib/telegram-bot'

mkdir -p "$CACHEDIR" "$LOGDIR" "$DBDIR"
chmod 0700 "$CACHEDIR" "$LOGDIR" "$DBDIR"

# FIXME: Need a UID for the bot
chown palmer "$CACHEDIR" "$LOGDIR" "$DBDIR"

# TODO: The following will only work on Debian; need to bang out
# on other operating systems.
sudo apt install \
	imagemagick \
	libconfig-ini-perl \
	libdatetime-perl \
	libdbd-mysql-perl \
	libdbi-perl \
	libjson-maybexs-perl \
	libtime-duration-perl \
	liblog-log4perl-perl \
	libmoose-perl \
	libuniversal-require-perl \
	liburi-encode-perl \
	libwww-perl \
	perl \
	perl-base

exit 0
