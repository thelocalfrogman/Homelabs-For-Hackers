# GNS3 Introduction

VirtualBox gives you VMs. GNS3 gives you networks. If you want to practice routing, segmentation, or anything that involves packets moving through actual network infrastructure, GNS3 is where it happens.

## Why GNS3 in a cyber range?

A real network isn't just endpoints talking directly to each other. There are routers, switches, firewalls, different subnets, VLANs. Traffic flows through infrastructure, and that infrastructure can be configured, misconfigured, monitored, and attacked.

GNS3 lets you:
- Build realistic network topologies with routers and switches
- Create multiple network segments that actually route traffic properly
- Run VMs natively using [QEMU](https://www.qemu.org/) — no need for a separate hypervisor
- Capture packets anywhere in the topology
- Practice network attacks and defences (ARP spoofing, routing attacks, VLAN hopping)

## When to use GNS3

If all you need is two VMs talking to each other, VirtualBox with a host-only network will get you there faster. But GNS3's VirtualBox integration is no longer supported, so if you're building anything with network infrastructure between your VMs, it's worth going straight to GNS3 with QEMU from the start.

| Use case | Approach |
|----------|----------|
| Two VMs need to talk directly | VirtualBox host-only network is fine or a simple GNS3 topology with a switch |
| You want traffic to pass through a router/firewall | GNS3 with router appliances |
| You want to practice network segmentation | GNS3 with multiple subnets |
| You want to capture traffic between segments | GNS3 (packet capture on any link) |
| You're learning firewall rules between subnets | GNS3 with a router/firewall image |
| You just want to run Nmap against a target | VirtualBox is plenty, even a basic GNS3 setup can be overkill |

## Installation

GNS3 runs differently depending on your platform. The key difference is how QEMU (the engine that runs your VMs) operates.

**DISCLAIMER:** These instructions are current as of 27/02/2026. Maintainers will endeavour to keep the below instructions up-to-date but software changes all the time. ALWAYS refer to the offical documentation as well as this.

### Linux Installation (Recommended)
[Offical GNS3 Linux installation documentation](https://docs.gns3.com/docs/getting-started/installation/linux/).

On Linux, GNS3 runs QEMU/KVM natively on your host. This gives you near-native VM performance since KVM uses hardware virtualisation directly. No extra VM layer needed.

```bash
sudo add-apt-repository ppa:gns3/ppa
sudo apt update
sudo apt install gns3-gui gns3-server
```

You'll need to add your user to several groups for proper permissions:

```bash
sudo usermod -aG ubridge,libvirt,kvm,wireshark $(whoami)
```

Log out and back in for group changes to take effect.

Verify KVM support is available:

```bash
kvm-ok
```

If `kvm-ok` reports that KVM acceleration can be used, you're set. If not, enable virtualisation (VT-x/AMD-V) in your BIOS/UEFI.

Install QEMU if it wasn't pulled in as a dependency:

```bash
sudo apt install qemu-system-x86 qemu-utils
```

When you launch GNS3 for the first time, choose **Run appliances on my local computer**. The local GNS3 server will handle everything, and QEMU VMs will run directly on your hardware with KVM acceleration.

### Windows Installation
[Offical GNS3 Windows installation documentation](https://docs.gns3.com/docs/getting-started/installation/windows).

The simplest method is via the GNS3 GUI installer. The instructions for this are in the offical documentation linked above and if you're just starting out I would recommend simply doing that. Otherwise you can follow the standalone GNS3 VM instructions below.

#### GNS3 VM
The offical GNS3 VM instructions can be found [here](https://docs.gns3.com/docs/getting-started/installation/download-gns3-vm).

On Windows, QEMU doesn't have access to KVM, so running VMs directly on the host can be slow. Instead, GNS3 uses the **GNS3 VM** — a lightweight Linux VM that runs the GNS3 server and QEMU/KVM inside it. Your Windows GNS3 client connects to this VM as its compute backend.

You have two options for running the GNS3 VM on Windows:

> **Note:** The GNS3 VM can technically run in VirtualBox as well, but VirtualBox's nested virtualisation support is limited and less reliable compared to VMware or Hyper-V, which can result in poor performance or KVM failing to initialise inside the GNS3 VM.

**Option A: VMware Workstation (recommended)**

1. Download and install [GNS3](https://www.gns3.com/software/download) — during installation, let it install all bundled components
2. Download the **GNS3 VM** from the same download page (grab the VMware version, it's a `.ova` file)
3. Install [VMware Workstation Pro](https://www.vmware.com/products/workstation-pro.html) (free for personal use)
4. Import the GNS3 VM `.ova` into VMware: **File > Open**, select the `.ova`
5. Before booting, adjust the VM settings:
   - Give it at least 4 GB RAM (more is better — this VM runs all your lab VMs inside it)
   - Allocate at least 2 CPU cores
   - Enable **Virtualize Intel VT-x/EPT or AMD-V/RVI** under Processors (this enables nested virtualisation so QEMU inside the VM can use KVM)
6. Boot the GNS3 VM. It will display an IP address on the console
7. In the GNS3 client: **Edit > Preferences > Server > GNS3 VM**, select VMware as the virtualisation engine, and it should auto-detect the running VM

**Option B: Hyper-V**

If you're on Windows 10/11 Pro or Enterprise, Hyper-V is built in. Note that Hyper-V and VMware Workstation can coexist on modern versions, but if you'd rather use Microsoft's hypervisor:

1. Enable Hyper-V: **Settings > Apps > Optional Features > More Windows Features > Hyper-V**
2. Download the Hyper-V version of the GNS3 VM (`.zip` containing a `.vhdx`)
3. In Hyper-V Manager, create a new VM pointing to the downloaded disk
4. Enable nested virtualisation for the VM in an elevated PowerShell:
   ```powershell
   Set-VMProcessor -VMName "GNS3 VM" -ExposeVirtualizationExtensions $true
   ```
5. Allocate RAM and CPUs as above
6. Boot and configure in GNS3 client the same way

**Which to choose?** VMware is the more battle-tested path for GNS3 and generally has fewer quirks. Hyper-V works well too but occasionally has networking edge cases. Either way, the key is enabling nested virtualisation so KVM works inside the GNS3 VM.

## Running VMs in GNS3 with QEMU

GNS3 still includes VirtualBox integration in current versions, it hasn't been officially deprecated or removed. It's more accurate to say it's been de-prioritised or is less actively maintained, and that QEMU is the recommended approach.

Running VMs directly inside GNS3 using QEMU means your VMs are first-class citizens in the topology — you drag them onto the canvas, connect them to switches and routers, and they just work. No bridging, no host-only adapters, no messing with Cloud nodes.

### Step 1: Get your disk images

You need QEMU-compatible disk images (`.qcow2` is the standard format). You can either download pre-built appliances or create your own from ISOs.

**Converting an existing image to qcow2:**

If you have VMs from VirtualBox (`.vdi`), VMware (`.vmdk`), or Hyper-V (`.vhd`/`.vhdx`), you can convert them rather than reinstalling from scratch:

```bash
# From VirtualBox
qemu-img convert -f vdi source.vdi -O qcow2 output.qcow2

# From VMware
qemu-img convert -f vmdk source.vmdk -O qcow2 output.qcow2

# From Hyper-V
qemu-img convert -f vhdx source.vhdx -O qcow2 output.qcow2
```

This is the easiest migration path if you've been running your range in VirtualBox and want to move everything into GNS3.

**Creating a fresh image from an ISO:**

```bash
# Create a blank disk
qemu-img create -f qcow2 kali-linux.qcow2 60G

# Boot from ISO to install (do this outside GNS3, it's easier)
qemu-system-x86_64 -enable-kvm -m 4096 -smp 2 \
  -hda kali-linux.qcow2 \
  -cdrom kali-linux-2025.1-installer-amd64.iso \
  -boot d -vnc :1
```

Connect to the VNC display (e.g., with a VNC viewer on `localhost:5901`), install the OS, shut down, and you have a ready-to-use `.qcow2` image.

On Windows, you'd do this step inside the GNS3 VM's terminal, or create the image on a Linux machine and transfer it.

**Pre-built GNS3 appliances:**

GNS3 has a marketplace of appliances (`.gns3a` files) that automate image setup. Go to **File > Import Appliance** or browse the [GNS3 Marketplace](https://gns3.com/marketplace/appliances). Many common images are available — Kali, various Linux distros, security appliances like pfSense, VyOS, and OpenWrt.

### Step 2: Add the QEMU VM template to GNS3

1. In GNS3: **Edit > Preferences > QEMU > Qemu VMs > New**
2. Give it a name (e.g., `Kali-Attacker`)
3. Set the compute backend:
   - **Linux**: Select your local server
   - **Windows**: Select the GNS3 VM
4. Set RAM (e.g., 4096 MB for Kali, 2048 MB for lightweight targets)
5. Select the console type — **VNC** is the safest choice and gives you a graphical console. Use **telnet** if it's a headless/CLI-only system
6. Browse to your `.qcow2` image for the disk
7. Finish the wizard

**Tuning the template (recommended):**

After creation, select the VM template and click **Edit**:

- **General**: Set vCPUs (2 is usually enough)
- **HDD**: Confirm your qcow2 is set as hda
- **Network**: Set the number of network adapters (1 is fine for most endpoints, more if you need multiple interfaces)

### Step 3: Use VMs in your topology

Your QEMU VMs now appear in the GNS3 device panel under **End devices**. Drag them onto the canvas like any other device. Connect their network interfaces to switches or routers. Right-click and start them. Double-click (or right-click > Console) to open the VNC/console window.

That's it. The VM is running inside GNS3's compute engine, its network interfaces are wired directly into the topology, and there's no bridging or host-only adapter configuration to mess with.

## Your first topology

Let's build something simple: a router connecting two LANs.

```
┌──────────────┐         ┌──────────────┐
│   LAN A      │         │    LAN B     │
│ 10.0.1.0/24  │         │ 10.0.2.0/24  │
│              │         │              │
│  ┌────────┐  │         │  ┌────────┐  │
│  │ PC-A   │  │         │  │ PC-B   │  │
│  │ .10    │  │         │  │ .10    │  │
│  └────┬───┘  │         │  └────┬───┘  │
│       │      │         │       │      │
│  ┌────┴───┐  │         │  ┌────┴───┐  │
│  │Switch-A│  │         │  │Switch-B│  │
│  └────┬───┘  │         │  └────┬───┘  │
└───────┼──────┘         └───────┼──────┘
        │                        │
        │    ┌──────────┐        │
        └────┤  Router  ├────────┘
             │ e0: .1   │
             │ e1: .1   │
             └──────────┘
```

### Step 1: Get a router image

GNS3 doesn't ship with router images due to licensing. You have options:

**Open source / free:**
- VyOS (free, Linux-based router) — great for learning
- OpenWrt
- pfSense (if you want firewall practice too)

**If you have access to Cisco images:**
- IOS images work well in GNS3 (you need a valid licence... which you can find out there on the interwebs)

For this guide, we'll assume you're using something like VyOS or a simple Linux router. Import it as a QEMU VM template using the steps above.

### Step 2: Create the topology

1. Open GNS3
2. Create a new project: **File > New Project**, name it `two-lan-range`
3. Drag a router from the device panel onto the canvas
4. Drag two switches onto the canvas
5. For a quick test, drag two VPCS devices (simple lightweight endpoints built into GNS3) onto the canvas
    - We will look at swapping these for full QEMU VMs shortly
6. Connect them:
   - Router port 1 to Switch-A
   - Router port 2 to Switch-B
   - PC-A to Switch-A
   - PC-B to Switch-B

### Step 3: Configure IP addresses

Start all devices (right-click > Start, or the green play button).

**On the router** (exact commands depend on your router image, this is pseudocode):

```
# Interface to LAN A
interface eth0
  ip address 10.0.1.1/24
  no shutdown

# Interface to LAN B  
interface eth1
  ip address 10.0.2.1/24
  no shutdown
```

**On PC-A** (double-click to open console):

```
ip 10.0.1.10/24 10.0.1.1
```

**On PC-B:**

```
ip 10.0.2.10/24 10.0.2.1
```

### Step 4: Test connectivity

From PC-A:
```
ping 10.0.2.10
```

If the router is configured correctly, you should get replies from PC-B.

### Step 5: Swap in real VMs

Once the topology works with VPCS, replace the VPCS nodes with your actual QEMU VMs. Delete a VPCS node, drag your Kali or Ubuntu QEMU VM template onto the canvas in its place, and reconnect the link. The VM gets a real operating system, real tools, and its traffic flows through the same GNS3 network infrastructure.

## Packet capture basics

This is one of the killer features of GNS3. You can capture packets on any link.

1. Right-click any link (the line connecting two devices)
2. Select **Start capture**
3. Choose the interface
4. Wireshark opens with a live capture

You can watch traffic flow between segments, see routing in action, and analyse what your attacks look like on the wire. This is incredibly useful for understanding how attacks work at the packet level.

### What "good traffic" looks like

When things are working:
- ARP requests and replies as devices discover each other
- ICMP echo requests and replies when you ping
- TCP handshakes (SYN, SYN-ACK, ACK) when connections establish
- Regular packet flow with reasonable TTL values

When things are broken:
- ARP requests with no replies (device unreachable at layer 2)
- ICMP "destination unreachable" messages
- TCP SYN packets with no response (filtered or no route)
- TTL expired messages (routing loops)

## Troubleshooting: Why nothing can ping

### Check 1: Are all devices started?

Right-click each device. It should say "Stop" (meaning it's running). If it says "Start", it's not running.

### Check 2: Are interfaces up?

On routers and switches, interfaces often default to administratively down. You need to bring them up.

### Check 3: Are IP addresses correct?

Double-check subnets. If PC-A is `10.0.1.10/24` and the router interface is `10.0.2.1/24`, they're not on the same subnet and can't communicate directly.

### Check 4: Is there a route?

If PC-A wants to reach PC-B, it needs a default gateway pointing to the router. The router needs to know how to reach both subnets (which it does, if its interfaces are configured correctly).

### Check 5: Capture and look

Start a packet capture on the link. Send a ping. See what happens. No packets? Layer 2 issue. Packets sent but no reply? Layer 3 issue.

### QEMU-specific troubleshooting

**VM won't start:** Check that your qcow2 image path is correct in the template settings. On Windows, make sure the GNS3 VM is running and that the image has been uploaded to it (GNS3 handles this automatically when you select a local file, but sometimes it needs a nudge).

**VM starts but no network:** Verify the number of adapters in the QEMU template matches how many links you've connected. If you've only configured 1 adapter but connected 2 links, the second link won't work.

**VM is extremely slow:** On Linux, verify KVM is being used (`-enable-kvm` should appear in the QEMU command line - check under template Advanced settings). On Windows, verify nested virtualisation is enabled on the GNS3 VM. Without KVM, QEMU falls back to software emulation and performance drops dramatically.

**Console won't open:** If using VNC, make sure no other process is binding the VNC port. Try changing the console type to telnet temporarily to verify the VM is actually running.

## Managing disk images

A few practical tips for working with QEMU disk images:

**Snapshots within qcow2:** QEMU's qcow2 format supports internal snapshots. This is useful for reverting a target VM to a clean state after you've compromised it:

```bash
# Take a snapshot
qemu-img snapshot -c clean-state target.qcow2

# List snapshots
qemu-img snapshot -l target.qcow2

# Revert to a snapshot
qemu-img snapshot -a clean-state target.qcow2
```

**Linked clones:** If you want multiple copies of the same base VM (e.g., several identical targets), use backing files to save disk space:

```bash
# Create a linked clone based on the original
qemu-img create -f qcow2 -b base-ubuntu.qcow2 -F qcow2 clone-1.qcow2
qemu-img create -f qcow2 -b base-ubuntu.qcow2 -F qcow2 clone-2.qcow2
```

Each clone only stores the differences from the base image, saving significant disk space.

**Image location:**
- **Linux (local server):** Images are stored wherever you point to them, but GNS3 defaults to `~/GNS3/images/QEMU/`
- **Windows (GNS3 VM):** When you add an image, GNS3 uploads it into the GNS3 VM automatically. Images live inside the VM's filesystem at `/opt/gns3/images/QEMU/`

## What's next?

With GNS3 in your toolkit, you can:

- Build segmented networks that mirror real environments
- Practice attacking across network boundaries
- Understand how traffic flows through infrastructure
- Add firewalls to your topology (see [OPNsense guide](06-firewall-opnsense.md))
- Practise defensive techniques like network monitoring and IDS placement

For network design inspiration, see [Network Design and Segmentation](07-network-design-and-segmentation.md).