# OPNsense Firewall

A firewall in your range does three things: controls what can talk to what, logs traffic for analysis, and adds realism. Real networks have firewalls. Your range should too.

OPNsense is a solid choice. It's free, well-documented, and has enough features to keep you busy for years without being overwhelming.

## Hardware (or virtual hardware) requirements

OPNsense needs at least two network interfaces: one for WAN (outside) and one for LAN (inside). For a range, you'll want more.

### Minimum

- 2 NICs (or virtual network adapters)
- 1 GB RAM (2 GB recommended)
- 8 GB disk

### Recommended for a range

- 3 or more NICs:
  - WAN: management access (and internet if needed)
  - LAN1: attacker segment
  - LAN2: target segment
- 2 GB RAM
- 20 GB disk (more if you want extensive logging)

### In VirtualBox

Create a VM with:
- 2048 MB RAM
- 20 GB disk
- 3 network adapters:
  - Adapter 1: Host-only (for management access from your host)
  - Adapter 2: Internal Network named `attacker-net`
  - Adapter 3: Internal Network named `target-net`

### In Proxmox

Create a VM with:
- 2048 MB RAM
- 20 GB disk
- 3 network interfaces:
  - net0: `vmbr0` (management/WAN)
  - net1: `vmbr1` (attacker segment)
  - net2: `vmbr2` (target segment)

## Installation

1. Download the OPNsense ISO from [opnsense.org/download](https://opnsense.org/download/)
2. Boot your VM from the ISO
3. Log in as `installer` with password `opnsense`
4. Follow the installer:
   - Accept defaults for keymap and filesystem
   - Wait for installation to complete
   - Reboot
5. Remove the ISO and boot from disk

On first boot, OPNsense will try to configure interfaces. If it gets confused, you can manually assign them.

## Interface configuration

After installation, you'll land at a console menu. Let's configure interfaces.

### Assign interfaces

If OPNsense didn't auto-detect correctly:

1. Select option `1` to assign interfaces
2. Skip VLAN setup for now (enter `n`)
3. Assign your interfaces:
   - WAN: the interface connected to your management network (e.g., `em0`)
   - LAN: your first internal network (e.g., `em1`)
   - OPT1: your second internal network (e.g., `em2`)

### Set interface IPs

Select option `2` to set interface IPs.

**For WAN:**
- Configure via DHCP if your management network has DHCP
- Or set a static IP in your management subnet

**For LAN (attacker segment):**
- IPv4 address: `10.10.10.1`
- Subnet: `24`
- Enable DHCP: yes (optional)
- DHCP range: `10.10.10.100` to `10.10.10.200`

**For OPT1 (target segment):**
- IPv4 address: `10.10.20.1`
- Subnet: `24`
- Enable DHCP: yes (optional)
- DHCP range: `10.10.20.100` to `10.10.20.200`

## Web interface access

Once WAN is configured with an IP, access the web interface:

1. From your host machine, browse to `https://YOUR-WAN-IP`
2. Accept the certificate warning
3. Log in: username `root`, password `opnsense`
4. Run through the setup wizard, or skip it and configure manually

## First ruleset: Allow what's needed, deny the rest

By default, OPNsense blocks traffic between interfaces. This is good. Now you'll create rules to allow specific traffic.

### The philosophy

- **Default deny.** If there's no rule allowing it, it's blocked.
- **Allow what's required.** Be specific about what needs to talk to what.
- **Log interesting things.** Visibility is the point.

### Creating your first rules

Go to **Firewall > Rules > LAN** (this is your attacker segment).

**Rule 1: Allow attackers to reach targets**

- Action: Pass
- Interface: LAN
- Protocol: Any (or be specific if you prefer)
- Source: LAN net
- Destination: OPT1 net
- Description: "Allow attacker to target segment"
- Log: Check this box

Click Save.

**Rule 2: Allow attackers to access the internet (optional)**

Only if you want your attacker segment to have internet for updates:

- Action: Pass
- Interface: LAN
- Protocol: Any
- Source: LAN net
- Destination: Any
- Description: "Allow attacker internet access"

Click Save.

Now go to **Firewall > Rules > OPT1** (target segment).

**Rule 3: Block targets from reaching attackers**

Actually, the default deny handles this. But you might want an explicit rule for logging:

- Action: Block
- Interface: OPT1
- Protocol: Any
- Source: OPT1 net
- Destination: LAN net
- Description: "Block targets from reaching attackers"
- Log: Check this box

**Rule 4: Block targets from reaching the internet**

Same idea:

- Action: Block
- Interface: OPT1
- Protocol: Any
- Source: OPT1 net
- Destination: Any
- Description: "Block targets from internet"
- Log: Check this box

Click **Apply Changes** at the top.

## Verification

### Test from each segment

**From your attacker VM (10.10.10.x):**

```bash
# Can you reach the firewall?
ping 10.10.10.1

# Can you reach a target?
ping 10.10.20.X

# Can you reach the internet? (if you allowed it)
ping 8.8.8.8
```

**From your target VM (10.10.20.x):**

```bash
# Can you reach the firewall?
ping 10.10.20.1

# Can you reach the attacker? (should fail)
ping 10.10.10.X

# Can you reach the internet? (should fail)
ping 8.8.8.8
```

### Confirm logs show traffic

Go to **Firewall > Log Files > Live View**.

Generate some traffic (pings, scans) and watch the logs populate. You should see your allowed and blocked traffic with timestamps, source, destination, and action taken.

This is the start of visibility. You can see what's happening in your range.

### Backing up your firewall config
OPNsense stores its entire configuration in a single XML file. This means you can back up and restore your firewall setup independently of VM snapshots, which is handy if you want to rebuild on different hardware or share your config between ranges.

The official documentation to backup/restore the config manually as well as automatically can be found [here](https://docs.opnsense.org/manual/backups.html). Keep in mind that if you're keeping snapshot's it's not 100% nesseaery, but it is recommended.

**A note on sensitive data**
- The config file contains password hashes and potentially certificates. Treat it like you'd treat any sensitive file, so don't commit it to a public repo or leave it sitting in a shared folder.

## Optional extras

### VLANs

If you have limited physical NICs but want more segments, VLANs let you run multiple logical networks over a single interface. OPNsense supports them well.

**Interfaces > Other Types > VLAN** to create VLAN interfaces, then assign them like physical interfaces.

### Aliases

Instead of typing IP addresses repeatedly, create aliases:

**Firewall > Aliases**

- Name: `Attackers`
- Type: Network
- Content: `10.10.10.0/24`
<br><br>
- Name: `Targets`
- Type: Network
- Content: `10.10.20.0/24`

Now use `Attackers` and `Targets` in your rules instead of raw IPs. Easier to read, easier to update.

### Port-based rules

Instead of allowing all traffic, be specific:

- Allow attackers to reach targets on port 22 (SSH), 80 (HTTP), 443 (HTTPS)
- Block everything else

More realistic, and forces you to think about what services you're actually testing.

### Logging to external SIEM

OPNsense can send logs via syslog to an external system (your logging VM, a SIEM, whatever).

**System > Settings > Logging / Targets**

Add a remote syslog destination with your logging server's IP. Now your firewall logs feed into your centralised logging.

## Common issues

### "WAN interface has no IP"

- Check the network adapter is connected
- Check your management network has DHCP, or set a static IP
- In VirtualBox, ensure "Cable Connected" is checked

### "LAN interface can't ping anything"

- Verify the interface is assigned correctly
- Check the IP is configured
- Check the VM is on the correct network

### "Rules don't seem to work"

- Did you click "Apply Changes"?
- Check rule order (rules are processed top to bottom, first match wins)
- Check you're testing from the right segment

### "I locked myself out of the web interface"

Access the console (VM console or physical keyboard) and use option `2` to reconfigure interface IPs, or option `4` to reset to factory defaults.

## What's next?

With a firewall in place:

- Your range has proper segmentation
- You can log and review traffic
- You're one step closer to realistic network defence practice

For network design patterns, see [Network Design and Segmentation](07-network-design-and-segmentation.md).

For detection and logging, see [Blue Team Basics](10-blue-team-basics.md).