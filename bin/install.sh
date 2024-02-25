#!/bin/sh
# telegram-bot
# Copyright (c) 2023-2024, Rev. Duncan Ross Palmer (2E0EOL),
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  3. Neither the name of the project nor the names of its contributors
#     may be used to endorse or promote products derived from this software
#     without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE PROJECT AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.

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

chown telegram-bot "$CACHEDIR" "$LOGDIR" "$DBDIR"

# TODO: The following will only work on Debian; need to bang out
# on other operating systems.
sudo apt install \
	imagemagick \
	jq \
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
