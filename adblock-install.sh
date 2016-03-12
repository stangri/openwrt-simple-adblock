#!/bin/sh
pixelservip=192.168.3.254

[ -f /etc/config/adblock ] && echo "FAIL: Current adblock installation detected!" && exit 1

opkg update
opkg install uhttpd wget openssl-util coreutils-sort libopenssl


# === PIXELSERV ===
if [ ! $(uci -q get uhttpd.pixelserv.listen_http) ]; then
echo 'Setting up Pixelserv'
mkdir /www_blank
echo -ne 'GIF89a1010\x8000\xff\xff\xff000!\xf9\x0400000,000010100\x02\x02D10;' | tr 01 '\000\001' > /www_blank/blank.gif
uci add uhttpd uhttpd
uci rename uhttpd.@uhttpd[-1]=pixelserv
uci add_list uhttpd.@uhttpd[-1].listen_http=0.0.0.0:81
uci set uhttpd.@uhttpd[-1].home=/www_blank
uci set uhttpd.@uhttpd[-1].rfc1918_filter=1
uci set uhttpd.@uhttpd[-1].max_requests=3
uci set uhttpd.@uhttpd[-1].error_page=/blank.gif
uci set uhttpd.@uhttpd[-1].index_page=blank.gif
uci set uhttpd.@uhttpd[-1].network_timeout=30
uci set uhttpd.@uhttpd[-1].tcp_keepalive=1
uci commit uhttpd
/etc/init.d/uhttpd restart
fi

grep -q "iptables -w -t nat -A prerouting_rule -p tcp -d $pixelservip --dport 80 -j REDIRECT --to-ports 81" /etc/firewall.user || echo "iptables -w -t nat -A prerouting_rule -p tcp -d $pixelservip --dport 80 -j REDIRECT --to-ports 81" >> /etc/firewall.user
grep -q "iptables -w -t nat -A prerouting_rule -p tcp -d $pixelservip -j ACCEPT" /etc/firewall.user || echo "iptables -w -t nat -A prerouting_rule -p tcp -d $pixelservip -j ACCEPT" >> /etc/firewall.user
grep -q "iptables -w -A forwarding_rule -d $pixelservip -j REJECT" /etc/firewall.user || echo "iptables -w -A forwarding_rule -d $pixelservip -j REJECT" >> /etc/firewall.user
/etc/init.d/firewall restart >/dev/null  2>&1

# === ADBLOCK ===
echo 'Setting up Adblock Service'
touch /etc/config/adblock
uci set adblock.config=adblock
uci set adblock.config.enabled=1
uci set adblock.config.noise=2
uci set adblock.config.pixel_server_ip=$pixelservip
uci set adblock.config.hosts_file=/tmp/hosts/hosts.bad
uci add_list adblock.config.whitelist_domains=github.com
uci add_list adblock.config.whitelist_domains=raw.githubusercontent.com
uci add_list adblock.config.blacklist_domains=adblocktesting.com
uci add_list adblock.config.bad_hosts='https://raw.githubusercontent.com/stangri/openwrt-simple-adblock/master/hosts.blocked'
uci add_list adblock.config.bad_hosts='http://pgl.yoyo.org/as/serverlist.php?hostformat=hosts&showintro=1&mimetype=plaintext'
uci add_list adblock.config.bad_hosts='http://www.mvps.org/winhelp2002/hosts.txt'
uci add_list adblock.config.bad_hosts='http://www.malwaredomainlist.com/hostslist/hosts.txt'
uci add_list adblock.config.bad_hosts='http://adaway.org/hosts.txt'
uci add_list adblock.config.bad_hosts='http://someonewhocares.org/hosts/hosts'
uci add_list adblock.config.bad_hosts='https://zeustracker.abuse.ch/blocklist.php?download=hostfile'
# The following four lists are pretty large and might cripple older routers with little RAM/flash
#uci add_list adblock.config.bad_hosts='http://sysctl.org/cameleon/hosts.win'									# 638Kb
#uci add_list adblock.config.bad_hosts='http://hosts-file.net/.\ad_servers.txt'								# 1.7Mb
#uci add_list adblock.config.bad_hosts='http://hostsfile.mine.nu/Hosts'												# 2.8Mb
#uci add_list adblock.config.bad_hosts='http://support.it-mate.co.uk/downloads/hosts.txt'			# 11.3Mb
uci add_list adblock.config.bad_domains='https://raw.githubusercontent.com/stangri/openwrt-simple-adblock/master/domains.blocked'
uci add_list adblock.config.bad_domains='https://palevotracker.abuse.ch/blocklists.php?download=domainblocklist'
uci add_list adblock.config.bad_domains='http://mirror1.malwaredomains.com/files/justdomains'
uci add_list adblock.config.bad_domains='https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt'
uci add_list adblock.config.bad_domains='http://dshield.org/feeds/suspiciousdomains_Low.txt'
uci add_list adblock.config.whitelist_urls='https://raw.githubusercontent.com/stangri/openwrt-simple-adblock/master/domains.whitelisted'
uci commit adblock
wget --no-check-certificate -qO /etc/init.d/adblock https://raw.githubusercontent.com/stangri/openwrt-simple-adblock/master/adblock
chmod +x /etc/init.d/adblock
# Set adblock to reload lists every month
grep -q '30 3 1 \* \* /etc/init.d/adblock reload 2>&1 >> /tmp/adblock.log' /etc/crontabs/root || echo '30 3 1 * * /etc/init.d/adblock reload 2>&1 >> /tmp/adblock.log' >> /etc/crontabs/root
	
# Comment two line below if you don't want the script to modify banner to reflect adblock status
[ ! -f /etc/banner.orig ] && cp /etc/banner /etc/banner.orig && sed -i '$i \[ -f /etc/banner.orig ] && cp /etc/banner.orig /etc/banner' /etc/rc.local

# Finally, start adblock:
/etc/init.d/adblock start  

# If start was successful, enable adblock to run on every boot-up
/etc/init.d/adblock enable
