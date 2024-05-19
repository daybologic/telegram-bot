#!/usr/bin/env bash

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

set -xeuo pipefail

umask 077

bucket=$(awk -F "=" '/bucket/ {print $2}' etc/telegram-bot.conf | tr -d ' ' | tr -d "'")

tempFileDir=$(mktemp meme-gif-to-mp4.XXXXXX --tmpdir -d)
json="${tempFileDir}/list.json"
aws --output json s3api list-objects --bucket "$bucket" > "$json"

gifs=$(jq -r '.Contents[] | select (.Key | endswith("gif")) | .Key' "$json")
for gif in $gifs; do
	storageClass=$(jq -r ".Contents[] | select (.Key == \"${gif}\") | .StorageClass" "$json")
	originalFileName=$(basename ${gif})
	remoteParent=$(dirname "${gif}")
	memeName=$(basename ${gif} .gif)
	mp4FileName="${memeName}.mp4"
	originalFilePath="${tempFileDir}/${originalFileName}"
	mp4FilePath="${tempFileDir}/${mp4FileName}"
	aws s3 cp "s3://${bucket}/${gif}" "${originalFilePath}"
	convert "${originalFilePath}" "${mp4FilePath}"
	aws s3 cp "--storage-class=$storageClass" "$mp4FilePath" "s3://${bucket}/${remoteParent}/${mp4FileName}"
	aws s3 rm "s3://${bucket}/${gif}"
	rm -f "${originalFilePath}" "${mp4FilePath}"
done

rm -f "$json"
rmdir "$tempFileDir"

exit 0
