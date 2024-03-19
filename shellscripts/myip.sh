#!/bin/bash
# Check the IP address of your system on the internet using 
# icanhazip.com
# See: https://blog.apnic.net/2021/06/17/how-a-small-free-ip-tool-survived/

echo -n "IPv4 Address: "
curl --ipv4 icanhazip.com
echo -n "IPv6 Address: "
curl --ipv6 icanhazip.com

