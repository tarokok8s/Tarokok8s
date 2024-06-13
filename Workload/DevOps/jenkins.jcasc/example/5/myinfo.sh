#!/bin/sh
echo "Content-type: text/html"
echo ""
echo '<head>'
echo '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
echo '</head>'
echo '<body>'
echo '<h2>Operating System</h2>'
grep 'PRETTY_NAME' /etc/os-release | cut -d'=' -f2
echo '<h2>Hostname</h2>'
hostname
echo '</body>'
exit 0
