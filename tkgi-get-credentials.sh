#!/bin/bash
/usr/bin/expect <<EOD
spawn  /usr/local/bin/tkgi get-credentials testproject
expect "Password"
send "$1\n"
expect eof
EOD