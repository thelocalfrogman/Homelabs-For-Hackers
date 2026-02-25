# Proxmox Upgrade Path

VirtualBox on a laptop is a great start. But if you've got dedicated hardware and want to run more VMs, manage them more easily, and stop worrying about your laptop overheating, Proxmox is the upgrade.

## Why Proxmox?

**Snapshots that don't suck.** Proxmox's snapshot and restore is fast and reliable. You can snapshot running VMs, revert in seconds, and manage it all from a web interface.

**Better multi-VM management.** When you're running 5 or more VMs, clicking through VirtualBox gets tedious. Proxmox gives you a dashboard, templates, cloning, and bulk operations.

**LXC containers.** For lightweight targets or services, you can run Linux containers instead of full VMs. Way less resource overhead.

**Long-term scaling.** Proxmox can cluster multiple machines, handle shared storage, and grow with you. Overkill for a starter range, but nice to know it's there.

**It's free.** Proxmox VE is open source. You can pay for support, but the core product is fully functional without a licence.

## Minimum specs

For a dedicated Proxmox box:

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 16 GB | 32 GB or more |
| Storage | 256 GB SSD | 500 GB or more SSD |
| CPU | 4 cores, virtualisation support | 6+ cores |
| NICs | 1 (for basic use) | 2 or more (for segmentation) |

### What to buy first

If you're upgrading an old desktop:

1. **SSD first.** Spinning disks make VM life miserable. Even a cheap 500 GB SATA SSD transforms the experience. This is the single biggest upgrade.

2. **RAM second.** After SSD, more RAM lets you run more VMs. Check your motherboard's maximum supported RAM before buying.

3. **NIC third.** If you want proper network segmentation with physical separation, add a second NIC. A used Intel dual-port gigabit card is cheap and works great with Proxmox.

CPU is usually fine. Most old desktops have enough cores for a starter range.

## Installation

1. Download the Proxmox VE ISO from [proxmox.com/en/downloads](https://www.proxmox.com/en/downloads)
2. Write it to a USB drive (use Rufus on Windows, `dd` on Linux, or Balena Etcher anywhere)
3. Boot from the USB
4. Follow the installer. It's straightforward.
   - Select the target disk (this will be wiped)
   - Set your country, timezone, keyboard
   - Set a root password and email (email can be fake for home use)
   - Configure networking (static IP recommended)
5. Reboot when complete
6. Access the web interface at `https://YOUR-IP:8006`

Accept the self-signed certificate warning. Log in as `root` with the password you set.

## Network bridges explained

This confuses a lot of people, so let's make it simple.

In Proxmox, a **bridge** is like a virtual switch. When you create a VM, you attach it to a bridge. All VMs on the same bridge can talk to each other.

### Default setup: vmbr0

When you install Proxmox, it creates `vmbr0` and bridges it to your physical NIC. VMs on `vmbr0` can reach your home network (and the internet, if your home network has internet).

```
[Physical NIC] <---> [vmbr0] <---> [Your VMs]
                        |
                        +--> [Your home network]
```

This is fine for VMs that need internet access. **Not fine for vulnerable targets.**

### Adding an isolated bridge: vmbr1

For your range, create a second bridge that's not connected to any physical NIC.

1. In Proxmox web UI: **Datacenter > Your Node > Network**
2. Click **Create > Linux Bridge**
3. Name: `vmbr1`
4. Leave everything else blank (no physical interface, no IP)
5. Click **Create**
6. Click **Apply Configuration**

Now `vmbr1` is an isolated network. VMs on `vmbr1` can talk to each other but can't reach your home network or the internet.

```
[vmbr1] <---> [Range VMs only]
   (no physical NIC attached, completely isolated)
```

Attach your attacker and targets to `vmbr1`. Attach your firewall to both `vmbr0` (for potential internet/management access) and `vmbr1` (to control range traffic).

### Multiple isolated networks

Need more segments? Create more bridges:

- `vmbr1`: Attacker segment
- `vmbr2`: Target segment
- `vmbr3`: Logging/management segment

Your firewall VM connects to all of them and controls what can talk to what.

## Creating VMs

1. Upload your ISO: **Datacenter > Your Node > local (storage) > ISO Images > Upload**
2. Click **Create VM** in the top right
3. Fill in the basics:
   - Name: `range-kali`
   - ISO: Select your uploaded ISO
   - Disk: 60 GB (adjust as needed)
   - CPU: 2 cores
   - Memory: 4096 MB
   - Network: Select your bridge (e.g., `vmbr1`)
4. Finish and start the VM
5. Click **Console** to see the VM's display and complete installation

## Backup and restore basics

Proxmox makes backups easy.

### Manual backup

1. Select your VM
2. Click **Backup**
3. Choose storage location, compression, mode
4. Click **Backup**

### Scheduled backups

1. **Datacenter > Backup**
2. Click **Add**
3. Select VMs, schedule, storage
4. Save

### Restore

1. Go to your storage (e.g., **local** or wherever backups live)
2. Find the backup file
3. Click **Restore**
4. Choose settings (new VM ID, etc.)
5. Restore

Backups are full VM images. Snapshots are faster for quick save points during labs. Use both.

## Migration note: When to move from VirtualBox

### Think about moving to Proxmox when:

- You're running 4+ VMs regularly
- Your laptop fan sounds like a jet engine
- You have dedicated hardware gathering dust
- You want to leave your range running while you do other things
- You want better snapshot management
- You're planning to add more machines later

### Stay on VirtualBox when:

- You only have one device
- You're just getting started and learning
- Your range needs are simple (1 attacker, 1 to 2 targets)
- You want portability (laptop goes where you go)

There's no rush. VirtualBox teaches the same concepts. Proxmox is a quality-of-life upgrade, not a requirement.

## Converting VirtualBox VMs to Proxmox

You don't have to rebuild everything from scratch.

### Export from VirtualBox

1. In VirtualBox: **File > Export Appliance**
2. Select your VM
3. Export as OVA

### Import to Proxmox

```bash
# SSH to your Proxmox host or use the shell in the web UI

# Extract the OVA (it's just a tar archive)
tar -xvf your-vm.ova

# Convert the VMDK to Proxmox format
qemu-img convert -f vmdk -O qcow2 your-vm-disk.vmdk your-vm-disk.qcow2

# Create a new VM in the web UI with no disk

# Import the converted disk
qm importdisk YOUR_VM_ID your-vm-disk.qcow2 local-lvm
```

Then attach the imported disk to your VM in the web UI and adjust settings.

Alternatively, just reinstall. Fresh installs are often cleaner, and you've got your snapshot and config notes from VirtualBox to guide you.

## What's next?

With Proxmox running:

- Set up isolated network bridges for your segments
- Deploy a firewall VM ([OPNsense guide](06-firewall-opnsense.md))
- Import or rebuild your attacker and target VMs
- Enjoy proper snapshots and easier management

For network design ideas, see [Network Design and Segmentation](07-network-design-and-segmentation.md).