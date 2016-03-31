[ -f /etc/config/adblock ] || echo "FAIL: Current adblock installation is NOT detected!" && exit 1

opkg update
opkg install wget coreutils-sort libopenssl

touch /etc/config/adblock
uci set adblock.config.enabled=1
uci set adblock.config.verbosity=2		# 1 for little verbosity, 2 for very verbose
uci add_list adblock.config.whitelist_domains=github.com
uci add_list adblock.config.whitelist_domains=raw.githubusercontent.com
uci add_list adblock.config.blacklist_domains=adblocktesting.com
uci add_list adblock.config.bad_hosts='https://raw.githubusercontent.com/stangri/openwrt-simple-adblock/master/hosts.blocked'
uci add_list adblock.config.bad_domains='https://raw.githubusercontent.com/stangri/openwrt-simple-adblock/master/domains.blocked'
uci add_list adblock.config.bad_domains='https://palevotracker.abuse.ch/blocklists.php?download=domainblocklist'
uci add_list adblock.config.bad_domains='http://mirror1.malwaredomains.com/files/justdomains'
uci add_list adblock.config.bad_domains='https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt'
uci add_list adblock.config.bad_domains='http://dshield.org/feeds/suspiciousdomains_Low.txt'
uci add_list adblock.config.whitelist_urls='https://raw.githubusercontent.com/stangri/openwrt-simple-adblock/master/domains.whitelisted'
uci commit adblock

# Comment two lines below if you don't want the script to modify banner to reflect adblock status
cp /etc/banner /etc/banner.orig
sed -i '$i \[ -f /etc/banner.orig ] && cp /etc/banner.orig /etc/banner' /etc/rc.local

echo -e -n 'Updating /etc/init.d/adblock script... ' && wget --no-check-certificate -qO /etc/init.d/adblock.new https://raw.githubusercontent.com/stangri/openwrt-simple-adblock/master/adblock && mv /etc/init.d/adblock.new /etc/init.d/adblock && chmod +x /etc/init.d/adblock && echo -e -n  'Done!\n' || echo -e -n 'FAIL!\n' 

# Finally, start adblock:
/etc/init.d/adblock reload  

# If start was successful, enable adblock to run on every boot-up
/etc/init.d/adblock enable
