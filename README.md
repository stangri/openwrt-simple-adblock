# OpenWrt Simple AdBlock
A simple DNSMASQ-based adblocking script for OpenWrt. Largely based on [bole5's](https://forum.openwrt.org/profile.php?id=45571) adblocking with performance improvements and added features.

If you want a more robust adblocking with documentation and Web UI support, check out [official OpenWrt adblock and luci-app-adblock packages](https://github.com/openwrt/packages/tree/master/net/adblock/files).

# Features
- Supports Attitude Adjustment, Chaos Calmer, Designated Driver and LEDE
- Doesn't stay in memory -- creates the list of blocked domains and then uses DNSMASQ and firewall to redirect requests to a 1x1 transparent gif served with uhttpd
- Supports both hosts files and domains lists for blocking
- Supports remote whitelist URLs, just put whitelisted domains one per line
- Supports whitelisted domains in config file
- Uses (lightweight) ufetch-client on DD/LEDE instead of wget
- As some of the standard lists URLs are using https, requires either wget/libopenssl (AA, CC) or libustream-mbedtls (DD/LEDE)
- Has setup function which installs dependencies and configures everything (/etc/init.d/adblock setup)
- Has update function which downloads updated script version from github.com (/etc/init.d/adblock update)
- Very lightweight and easily hackable, the whole script is just one /etc/init.d/adblock file
- Logs single entry in the system log with the number of blocked domains if verbosity is set to 0
- (Optionally) shows ad blocking status in the banner
- From version 2.0 onward (yes, I'm very generous with version numbers) retains the downloaded/sorted adblocking list on service stop and reuses it on service start (use reload if you want to force re-download of the list)
- From version 3.0 onward also elegantly blocks ads served over https

# Documentation / Discussion
There's no documentation and it's intentional -- you should use this script if you're comfortable reviewing its code. Otherwise, please use [official OpenWrt adblock and luci-app-adblock packages](https://github.com/openwrt/packages/tree/master/net/adblock/files).
Please head to OpenWrt forum for discussion of this script: https://forum.openwrt.org/viewtopic.php?pid=307950

# How to install
Telnet/ssh to your OpenWrt/LEDE router and run the following command: 
```wget --no-check-certificate -qO - https://raw.githubusercontent.com/stangri/openwrt-simple-adblock/master/adblock | /bin/sh -s setup```.
Please note that in order to succeed, this requires either wget/libopenssl or ufetch-client/libustream-mbedtls already installed on your router.

# What's New
3.3.1:
- Fixed bug with overzealous whitelisting due to the dot in domain names

3.3.0:
- Another rewrite of the output/logging logic to make AdBlock messages in the system log look prettier

3.2.0:
- One-line command for setup from github

3.1.0:
- Reworked output -- it now displays messages in the console and/or writes them to the system log

3.0.0:
- Changed default pixelserv IP to 198.18.0.1
- Switched uhttpd instance serving the blank pixel to a high-number port
- Added uhttpd instance to elegantly block ads served over https (thanks to @dibdot for the tutorial/code)
- If you're upgrading from any previous version, make sure to run /etc/init.d/adblock setup after an update

# Known Issues
There's no ipk-package. If you're willing to help with the Makefile, please create a pull request.

There are 4 very large blocklists which are not included by default as their inclusion will likely result in script termination on routers with little RAM/Flash. Check the *setup* function for commented out lines.

The script manipulates the /etc/banner file to reflect the status of the adblock _if_ the */etc/banner.orig* file exists. The setup function creates this file by default, comment it out if you want to keep your banner unmolested.
