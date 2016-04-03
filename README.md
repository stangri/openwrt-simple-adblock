# OpenWrt Simple Adblock
A simple DNSMASQ-based adblocking script for OpenWrt. Shamelessly stolen from bole5 at OpenWrt forums (https://forum.openwrt.org/profile.php?id=45571) with some performance and other improvements.

# Features
- Supports Attitude Adjustment, Chaos Calmer, Designated Driver
- Doesn't stay in memory -- creates the list of blocked domains and then uses DNSMASQ and firewall to redirect requests 1x1 transparent gif served with uhttpd
- Supports both hosts files and list of domains for blocking
- Supports remote whitelist URLs, just put whitelisted domains one per line
- Supports whitelisted domains in config file
- Uses ufetch-client on DD instead of wget
- As some of the standard lists URLs are using https, requires either wget/libopenssl (AA, CC) or ustream-ssl (DD)
- Has setup function which installs dependencies and configures everything (/etc/init.d/adblock setup)
- Has update function which downloads updated script version from github.com (/etc/init.d/adblock update)
- Has verbosity settings (adblock.config.verbosity, default value 2) controlling output verbosity
- Very lightweight, the whole script is just one /etc/init.d/adblock file
- Logs single entry in the system log with the number of blocked domains if verbosity is set to 0
- Shows ad blocking status in the banner (can be disabled)

# Discussion / Support
Please head to OpenWrt forum for discussion/support: https://forum.openwrt.org/viewtopic.php?pid=307950

# Known Issues
There's no ipk-package. If you're willing to help with the Makefile, please create a pull request.

There are 4 very large blocklists which are not included by default as their inclusion will likely result in script termination on routers with little RAM/Flash. Check the *adblock-install.sh* script for commented out lines.

The script manipulates the /etc/banner file to reflect the status of the adblock _if_ the */etc/banner.orig* file exists. The setup function creates this file by default, comment it out if you want to keep your banner unmolested.
