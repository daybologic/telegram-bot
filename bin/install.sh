#!/bin/sh

set -ex

CACHEDIR='/var/cache/telegram-bot'
mkdir -p "$CACHEDIR"
chmod 0700 "$CACHEDIR"

# FIXME: Need a UID for the bot
chown palmer "$CACHEDIR"

exit 0
