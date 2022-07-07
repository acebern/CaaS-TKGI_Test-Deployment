#!/bin/bash
/usr/bin/expect <<EOD
spawn tkgi get-credentials testCluster2
expect "Password"
send "$1\n"
expect eof
EOD