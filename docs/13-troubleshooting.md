# Troubleshooting

Things will break. This page covers the most common problems and how to fix them.

## No connectivity between VMs

The VMs can't ping each other.

### Quick checks

1. **Are both VMs on the same network?**
   - VirtualBox: Check both are on the same host-only or internal network
   - Proxmox: Check both are on the same bridge (vmbr1, etc.)

2. **Are the network cables "connected"?**
   - VirtualBox: Settings > Network > "Cable Connected" checkbox
   - Proxmox: Hardware > Network Device > check it's not disconnected

3. **Do both VMs have IPs in the same subnet?**
   - `ip addr` on Linux, `ipconfig` on Windows
   - 10.10.10.5 and 10.10.10.20 can talk. 10.10.10.5 and 10.10.20.5 cannot (different subnets).

4. **Is a firewall blocking traffic?**
   - Windows Firewall blocks ping by default. Test with a service connection instead, or disable firewall temporarily.
   - Linux: Check `iptables -L` or `ufw status`

5. **Is the interface up?**
   - Linux: `ip link show` - look for "UP" in the output
   - If down: `sudo ip link set eth0 up`

### Still broken?

Try these:

```bash
# On VM A, check interface and IP
ip addr show

# Check routing table
ip route

# Try to ping the gateway
ping GATEWAY-IP

# If that works, try pinging VM B
ping VM-B-IP

# Check ARP table
arp -a
```

If you can ping the gateway but not VM B, the issue is likely VM B's configuration or firewall.

## DHCP not working

VMs aren't getting IP addresses automatically.

### VirtualBox host-only network

1. Go to File > Tools > Network Manager
2. Select your host-only network
3. Click Properties > DHCP Server tab
4. Check "Enable Server"
5. Verify the range doesn't conflict with static IPs you're using
6. Apply

### OPNsense DHCP

1. Services > DHCPv4 > [Your Interface]
2. Check "Enable DHCP server on this interface"
3. Set a valid range within your subnet
4. Save and Apply

### Still not working?

```bash
# On the VM, release and renew
sudo dhclient -r
sudo dhclient eth0

# Or on newer systems
sudo dhcpcd eth0
```

Check if another DHCP server is responding (you might have duplicate DHCP servers on the network).

## OPNsense WAN down

The WAN interface has no IP or can't reach the internet.

### Quick checks

1. **Is the interface assigned correctly?**
   - Console menu option 1: Check interface assignments
   - WAN should be the interface connected to your management network or internet

2. **DHCP or static?**
   - If DHCP: Is there a DHCP server on the WAN network?
   - If static: Is the IP/gateway correct?

3. **Is the cable connected?**
   - Check the adapter settings in your hypervisor
   - In VirtualBox: "Cable Connected" checkbox

4. **Gateway reachable?**
   - Console: Option 7 for shell
   - `ping YOUR-GATEWAY-IP`

### Fixing from console

If you need to reconfigure:

1. Console option 2: Set interface IP addresses
2. Choose WAN
3. Configure DHCP or static as needed
4. Test with ping

## GNS3 links but nothing routes

Devices are connected in GNS3 but traffic doesn't flow.

### Check 1: Are all devices started?

Right-click each device. If it says "Start", it's not running. Start it.

### Check 2: Are interfaces up and configured?

On routers, interfaces often default to "administratively down".

```
# Generic router commands
interface eth0
  no shutdown
  ip address 10.0.1.1/24
```

### Check 3: Do endpoints have gateways?

VPCS and VMs need default gateways pointing to the router.

VPCS: `ip 10.0.1.10/24 10.0.1.1`

The second address is the gateway.

### Check 4: Does the router have routes?

If you have multiple subnets, the router needs to know how to reach them. For directly connected interfaces, this is automatic. For remote networks, you need static routes or routing protocols.

### Check 5: Capture and analyse

Right-click a link > Start Capture > open in Wireshark.

- No packets at all: Layer 2 issue (interface down, wrong connection)
- ARP requests with no replies: Destination not reachable at layer 2
- ICMP "destination unreachable": Routing issue

## Logging agent not checking in

Your Wazuh/SIEM agent is installed but not appearing in the manager.

### Quick checks

1. **Is the agent service running?**
   ```bash
   # Linux
   sudo systemctl status wazuh-agent
   
   # Windows
   Get-Service WazuhSvc
   ```

2. **Can the agent reach the manager?**
   ```bash
   # From the agent, test connectivity
   nc -zv MANAGER-IP 1514
   nc -zv MANAGER-IP 1515
   ```

3. **Is the manager address correct?**
   ```bash
   # Linux
   cat /var/ossec/etc/ossec.conf | grep -A2 server
   ```
   
   Look for the `<address>` field.

4. **Firewall blocking?**
   - Agent needs to reach manager on ports 1514 and 1515
   - Check both host firewalls and any network firewalls

### Re-registering the agent

Sometimes you need to re-register:

```bash
# On the agent
sudo /var/ossec/bin/agent-auth -m MANAGER-IP
sudo systemctl restart wazuh-agent
```

### Check manager logs

On the Wazuh manager:
```bash
tail -f /var/ossec/logs/ossec.log
```

Look for connection attempts and errors.

## VMs are incredibly slow

Everything lags, VMs are unresponsive.

### Check 1: RAM

Are you over-allocated? If your host has 16GB and you've given VMs 20GB total, you're swapping to disk.

```bash
# On host
free -h
```

If swap usage is high, reduce VM RAM allocations.

### Check 2: Disk I/O

Spinning disk? That's your problem. Get an SSD.

Check disk activity:
```bash
# On host
iostat -x 1
```

If `%util` is constantly near 100%, your disk is the bottleneck.

### Check 3: CPU

Check if CPU is maxed:
```bash
top
htop
```

If one VM is consuming all CPU, it might have a runaway process.

### Check 4: VirtualBox specific

- Guest additions installed? They help.
- Nested virtualisation enabled when not needed? Disable it.
- 3D acceleration enabled causing issues? Disable it.

### Check 5: Proxmox specific

- Using VirtIO drivers? You should be.
- Ballooning causing issues? Try disabling.
- Check the host isn't overcommitted.

## VirtualBox won't start / errors on launch

### "VT-x is not available"

Virtualisation isn't enabled in BIOS/UEFI.

1. Reboot into BIOS/UEFI
2. Find virtualisation settings (Intel VT-x, AMD-V, SVM Mode)
3. Enable them
4. Save and reboot

### "Kernel driver not installed" (Linux)

```bash
sudo /sbin/vboxconfig
```

If that fails, you might need kernel headers:
```bash
sudo apt install linux-headers-$(uname -r)
sudo /sbin/vboxconfig
```

### Hyper-V conflict (Windows)

VirtualBox and Hyper-V can conflict. Options:

1. Disable Hyper-V: 
   ```cmd
   bcdedit /set hypervisorlaunchtype off
   ```
   Reboot.

2. Or use newer VirtualBox with Hyper-V support (6.0+), but performance may suffer.

## General debugging approach

When something's broken:

1. **Isolate the problem.** What exactly isn't working?
2. **Check the obvious.** Power, cables, is it running?
3. **Check logs.** Every system has logs. Read them.
4. **Test layer by layer.** Can you ping? Can you reach the port? Can the service respond?
5. **Change one thing at a time.** If you change five things and it starts working, you don't know which one fixed it.
6. **Snapshot before experimenting.** Always.

## Still stuck?

- Search the error message. Someone's had this problem before.
- Check the specific tool's documentation.
- Ask in relevant communities (r/homelab, security Discord servers, etc.)
- Open an issue on this repo if it's related to these guides.

## What's next?

Problem solved? Get back to building:

- [Build guides](03-virtualbox-starter-range.md)
- [Lab scenarios](../labs/README.md)
- [Network design](07-network-design-and-segmentation.md)