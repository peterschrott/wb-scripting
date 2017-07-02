#!/bin/bash
#
# Sends a message to whizbags slack monitoring channel
#
# Usage: slackpost.sh message
# E.g.: slackpost.sh database backup status: Successful!
#
#
set -e
if [ "$#" -lt 1 ]; then
cat << EOF
Sends a message to whizbags slack monitoring channel

Usage: slackpost.sh message
E.g.: slackpost.sh database backup status: Successful!
EOF
    exit
fi

_MESSAGE=$*

###############################################################################

echo "sending message '$_MESSAGE' to whizbags slack monitoring channel..."

_ESCAPED_MESSAGE=$(echo $_MESSAGE | sed 's/"/\"/g' | sed "s/'/\'/g" )
_JSON="{\"channel\": \"#$_CHANNEL\", \"text\": \"$_ESCAPED_MESSAGE\"}"

curl -s -d "payload=$_JSON" "https://hooks.slack.com/services/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"

exit $?