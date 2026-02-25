# VirtualBox Starter Range

This is the $0 build. Everything here runs on your existing laptop or desktop using free software. By the end, you'll have an isolated network with an attacker VM and at least one target.

## What you'll build

```
┌─────────────────────────────────────────────────────┐
│                  Your Computer                      │
│                                                     │
│   ┌─────────────────────────────────────────────┐   │
│   │        Host-only Network: 192.168.56.0/24   │   │
│   │                                             │   │
│   │   ┌──────────┐    ┌──────────┐              │   │
│   │   │  Kali    │    │  Ubuntu  │              │   │
│   │   │ Attacker │    │  Target  │              │   │
│   │   │ .10      │    │  .20     │              │   │
│   │   └──────────┘    └──────────┘              │   │
│   │                                             │   │
│   └─────────────────────────────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```

No internet access for the VMs (unless you temporarily enable it). No connection to your home LAN. Just your attacker and target, isolated and ready.

## Prerequisites

- VirtualBox installed ([download here](https://www.virtualbox.org/wiki/Downloads))
- Kali Linux ISO downloaded
- Ubuntu Server or Desktop ISO downloaded (or Windows evaluation ISO)
- At least 16 GB RAM total on your host
- At least 60 GB free disk space

## Step 1: Create the host-only network

First, set up the isolated network your VMs will share.

1. Open VirtualBox
2. Go to **File > Tools > Network Manager** (or **File > Host Network Manager** on older versions)
3. Click **Create** to add a new host-only network
4. Select the new network and click **Properties**
5. Configure it:
   - IPv4 Address: `192.168.56.1`
   - IPv4 Network Mask: `255.255.255.0`
6. Click the **DHCP Server** tab
7. Either enable DHCP with a sensible range (e.g., `192.168.56.100` to `192.168.56.200`) or disable it if you prefer static IPs
8. Click **Apply**

You now have an isolated network called something like `vboxnet0`. Remember this name.

## Step 2: Build the attacker VM (Kali)

### Create the VM

1. Click **New** in VirtualBox
2. Name: `range-kali`
3. Type: Linux
4. Version: Debian (64-bit)
5. Memory: 4096 MB (This is perfectly fine but provide more if you have 32GB of RAM)
6. Create a virtual hard disk: VDI, dynamically allocated, 40-60 GB
   - Note that "dynamically allocated" means the VM will not reserve 60 GB of disk space, it will simply limit that VMs disk space amount to 60 GB. Read more [here](https://www.virtualbox.org/manual/ch05.html).

### Configure before first boot

1. Select the VM, click **Settings**
2. **System > Processor**: Give it 2 CPUs if you can spare them
3. **Storage**: Click the empty CD icon, then the CD icon on the right, choose your Kali ISO
4. **Network > Adapter 1**: 
   - Attached to: **Host-only Adapter**
   - Name: `vboxnet0` (or whatever your host-only network is called)

### Install Kali

1. Start the VM
2. Choose **Graphical Install**
3. Follow the prompts. Defaults are fine for most options.
4. When asked about disk partitioning, "Guided - use entire disk" is fine
5. Install GRUB to the primary drive when prompted
6. Finish installation and reboot
7. Remove the ISO from the virtual CD drive when prompted (or do it manually in Settings)

### Post-install

Log in and open a terminal:

```bash
# Set a static IP (optional but recommended)
sudo nano /etc/network/interfaces
```

Add:
```
auto eth0
iface eth0 inet static
    address 192.168.56.10
    netmask 255.255.255.0
```

Then:
```bash
sudo systemctl restart networking
```

Verify:
```bash
ip addr show eth0
```

You should see `192.168.56.10`.

### Snapshot now

This is your clean attacker VM. Snapshot it.

1. With the VM selected (can be running or stopped), go to **Machine > Take Snapshot**
2. Name it something like `clean-install`
3. Description: "Fresh Kali install, static IP configured, no extra tools"

## Step 3: Build a target VM (Ubuntu)

### Create the VM

1. Click **New**
2. Name: `range-ubuntu-target`
3. Type: Linux
4. Version: Ubuntu (64-bit)
5. Memory: 2048 MB (targets don't need much)
6. Create virtual hard disk: VDI, dynamically allocated, 40 GB

### Configure before first boot

1. **Storage**: Attach your Ubuntu ISO
2. **Network > Adapter 1**:
   - Attached to: **Host-only Adapter**
   - Name: `vboxnet0`

### Install Ubuntu

1. Start the VM
2. Choose **Install Ubuntu** (or "Install Ubuntu Server" if using server ISO)
3. Follow prompts. Defaults are fine.
4. Create a user. For a lab target, simple creds are fine: `labuser` / `labpass`
5. Finish installation

### Post-install

```bash
# Set static IP
sudo nano /etc/netplan/00-installer-config.yaml
```

Replace contents with:
```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      addresses:
        - 192.168.56.20/24
```

Apply:
```bash
sudo netplan apply
ip addr
```

You should see `192.168.56.20`.

### Make it a bit vulnerable (optional)

For your first lab, maybe install SSH and leave it with weak creds:

```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable ssh
```

Now you have an SSH service to scan and attempt to brute force.

### Snapshot

Name: `clean-target`
Description: "Fresh Ubuntu, SSH enabled, weak creds"

## Step 4: Verify connectivity

From your Kali VM:

```bash
ping 192.168.56.20
```

You should get replies.

From your Ubuntu target:

```bash
ping 192.168.56.10
```

Same deal.

Try scanning from Kali:

```bash
nmap -sV 192.168.56.20
```

You should see the SSH port (22) open.

Congratulations. You have a functional cyber range.

## Step 5 (Optional): Add a logging VM

If you want to start seeing attacks from the defender's perspective, add a third VM for logging. This could be:

- Another Ubuntu box running [Wazuh](https://wazuh.com/) agent and manager
- A lightweight syslog server
- An ELK stack if you have the RAM to spare

See [Blue Team Basics](10-blue-team-basics.md) for details.

## Common gotchas

### "My VMs can't ping each other"

- Check both VMs are on the same host-only network (`vboxnet0`)
- Check the "Cable connected" checkbox is ticked in network settings
- Verify IP addresses are in the same subnet
- Check no host firewall is blocking traffic

### "DHCP isn't giving out addresses"

- Verify DHCP is enabled in the host-only network settings
- Check the DHCP range doesn't conflict with static IPs you've set
- Try rebooting the VM

### "I can't install VirtualBox / it won't start"

- Ensure virtualisation is enabled in your BIOS/UEFI
- On Windows, check Hyper-V isn't conflicting (can coexist on newer VirtualBox versions but sometimes causes issues)
- On Linux, ensure your user is in the `vboxusers` group

### "Guest additions won't install"

For Kali:
```bash
sudo apt update
sudo apt install virtualbox-guest-x11
```

For Ubuntu:
```bash
sudo apt update
sudo apt install virtualbox-guest-utils virtualbox-guest-x11
```

Reboot after installing.

### "Everything is incredibly slow"

- You've probably over-allocated RAM. If your host is swapping, everything suffers.
- Reduce VM RAM allocation
- Close other applications on your host
- Consider an SSD if you're on a spinning disk

## Snapshot strategy

Get in the habit of snapshotting at milestones:

| Snapshot name | When to take it |
|---------------|-----------------|
| `clean-install` | Right after OS install, before any config |
| `configured` | After network config and basic setup |
| `lab-ready` | After installing tools/services for a specific lab |
| `pre-experiment` | Before trying something risky |

Name them clearly. Future you will be grateful.

## What's next?

You've got a working range. From here you can:

- [Add network complexity with GNS3](04-gns3-intro.md)
- [Deploy more vulnerable targets](09-vulnerable-targets.md)
- [Set up basic detection](10-blue-team-basics.md)
- [Run your first lab scenario](../labs/starter-range/README.md)