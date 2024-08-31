# Get IP address
"""
    Return the IP addresses (both public and private).
    
    Heavily uses regular expressions (see [1] for help). 
    Uses icanhazip for public IP address (see [2]).
    Flag descriptionns can be found under "SIOCGIFFLAGS, SIOCSIFFLAGS"
    at [3].
    
    [1]: https://regex101.com/
    [2]: https://blog.apnic.net/2021/06/17/how-a-small-free-ip-tool-survived/
    [3]: https://man7.org/linux/man-pages/man7/netdevice.7.html
"""

# %%
import re
import sys
import subprocess


# %%
def run_command(command, no_error:bool = True):
    """
        Run a `command`. If 'no_error' is True, then a ValueError is
        raised if a non-zero error code is encountered when running
        the `command`.
        This function returns the stdout of the `command`. Many 
        commands return a newline, a `[:-1]` will remove this.
    """
    try:
        res: subprocess.CompletedProcess = subprocess.run(command, 
                shell=True, executable="/bin/bash", 
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, 
                timeout=2)
    except subprocess.TimeoutExpired as err:
        return f"Error: {err}"
    if res.returncode != 0 and no_error:
        err_msg: bytes = res.stderr
        msg: str = err_msg.decode("utf-8")
        raise ValueError(f"Running '{command}' gave:\n"\
                f"\t{msg}")
    msg: bytes = res.stdout
    return msg.decode("utf-8")


# %%
if __name__ == "__main__":
    # Get public-facing IP addresses
    try:
        ipv4_addr = run_command("curl -m 5 --ipv4 icanhazip.com")[:-1]
        ipv6_addr = run_command("curl -m 5 --ipv6 icanhazip.com")[:-1]
        print("----------- Public IP addresses -----------")
        print(f"IPv4 address: {ipv4_addr}")
        print(f"IPv6 address: {ipv6_addr}")
    except ValueError as err:
        print(f"Error: {err}")
        print("Could not get the public facing IP addresses")
    # Get internal IP addresses
    ifaces = run_command("ip addr | awk '/^[0-9]+:/{print $2}'")[:-1]
    ifaces = [iface[:-1] for iface in ifaces.split("\n")]
    print(f"--------- System IP addresses ({len(ifaces)}) ---------")
    for iface in ifaces:
        if iface == "lo":
            print(f"> {iface} (loopback): ")
            print("  ├── IPv4: 127.0.0.1")
            print("  └── IPv6: ::1", end="")
        else:
            ifdetails = run_command(f"ip addr show {iface}")[:-1]
            print(f"> {iface}: ", end="")
            # Filter the tags (for information)
            tags: str = re.findall(r'<.*>', 
                    ifdetails.split("\n")[0])[0]
            tags = tags[1:-1].split(',')
            to_print = []
            for tag in tags:
                if tag == "BROADCAST":
                    to_print.append("Broadcast allowed")
                elif tag == "MULTICAST":
                    to_print.append("Multicast allowed")
                elif tag == "UP":
                    to_print.append("Interface active")
                elif tag == "NO-CARRIER":
                    to_print.append("No carrier (possibly virtual)")
                else:
                    to_print.append(tag)
            if "UP" not in tags:
                to_print.append("Possibly down/off")
            print("; ".join(to_print))
            # MAC address
            ifd_lines = ifdetails.splitlines()
            mac_addr = ifd_lines[1].strip().split(" ")[1]
            # IPv4 address
            ipv4_addrs = list(filter(lambda line: re.match(
                    r'\s+inet\s+', line) is not None, ifd_lines))
            ipv4_addrs = [elem.strip().split(" ")[1] \
                    for elem in ipv4_addrs] # Get XX.XX.XX.XX/XX
            ipv4_addrs = [elem.split("/")[0] for elem in ipv4_addrs]
            # IPv6 addresses
            ipv6_addrs = list(filter(lambda line: re.match(
                    r'\s+inet6\s+', line) is not None, ifd_lines))
            ipv6_addrs = [elem.strip().split(" ")[1] \
                    for elem in ipv6_addrs] # Get XX.XX.XX.XX/XX
            ipv6_addrs = [elem.split("/")[0] for elem in ipv6_addrs]
            # Display addresses
            for ipv4_addr in ipv4_addrs:
                print(f"  ├── IPv4: {ipv4_addr}")
            for ipv6_addr in ipv6_addrs:
                print(f"  ├── IPv6: {ipv6_addr}")
            print(f"  └── MAC Addr: {mac_addr}", end="")
        print("")

