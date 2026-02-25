# Start Here

You want to build a cyber range. Good. Let's figure out what you're working with and get you on the right path.

## Two paths

### Path A: I only have a laptop

No worries. Plenty of people start here. You'll use VirtualBox (free) and run everything as virtual machines on your existing computer. It works surprisingly well, especially for learning.

**Your next step:** [VirtualBox Starter Range](03-virtualbox-starter-range.md)

**Minimum specs:**
- 16 GB RAM (8 GB technically works but you'll feel it)
- 100 GB free disk space (SSD strongly preferred)
- CPU with virtualisation support (most modern CPUs have this)
- Any OS: Windows, macOS, or Linux

**What hurts first:** RAM. Every VM you spin up eats into it. With 16 GB you can comfortably run 2 to 3 VMs. With 8 GB, you'll be swapping to disk constantly and hating life.

### Path B: I have spare hardware

Maybe an old desktop, a mini PC, or that laptop with the cracked screen. Dedicated hardware means you can run more VMs, leave things running, and eventually move to Proxmox for easier management.

**Your next step:** Still start with [VirtualBox Starter Range](03-virtualbox-starter-range.md) to learn the concepts, then look at the [Proxmox Upgrade Path](05-proxmox-upgrade-path.md) when you're ready.

**Ideal specs for dedicated hardware:**
- 16-32 GB RAM (lets you run 5 to 8 VMs very comfortably)
- 256 GB SSD minimum, 500 GB or more preferred
- Any reasonably modern CPU (Intel 6th gen or AMD Ryzen and newer)
- A spare PCIe slot for a 2nd [NIC](https://en.wikipedia.org/wiki/Network_interface_controller) if you want proper network segmentation later

## The mental model

Before you touch any software, get this picture in your head:

**Networks:** Your range is made of isolated networks. Traffic in one network can't reach another unless you explicitly allow it. Your home LAN is one network. Your range networks are completely separate.

**Segments:** Within your range, you'll have different segments for different purposes. Attackers live in one segment. Victims live in another. Maybe you have a DMZ for things that simulate public-facing services. The firewall controls what can talk to what.

**Snapshots:** Before you break something, you snapshot it. Snapshots are your save points. Messed up a config? Revert. Finished a lab? Revert. Want to try something risky? Snapshot first, then go wild.

**Reset loops:** The whole point of a range is to break things, learn from it, then reset and do it again. You're not building a production environment that needs to stay up. You're building a disposable playground.

## Before you begin checklist

Do these things now. Future you will be grateful.

- [ ] **Check virtualisation is enabled in BIOS/UEFI.** Google your laptop or motherboard model plus "enable virtualisation" if you're not sure how.

- [ ] **Download your ISOs.** Waiting for downloads mid-build is painful. Grab these now:
  - [Kali Linux](https://www.kali.org/get-kali/) (installer ISO, not the VM image)
  - [Ubuntu Server](https://ubuntu.com/download/server) or [Desktop](https://ubuntu.com/download/desktop)
  - [Windows 10/11 Evaluation](https://www.microsoft.com/en-us/evalcenter/) (90-day free trial, perfect for labs)

- [ ] **Pick a naming scheme.** Sounds minor but saves confusion later. Something like:
  - `range-kali` for your attacker
  - `range-ubuntu-target` for victims
  - `range-opnsense` for your firewall
  
  Or use a theme. Name them after planets, Simpsons characters, whatever helps you remember what's what.

- [ ] **Clear some disk space.** VMs add up. Each one is typically 20 to 60 GB. Running low on space mid-install is frustrating.

- [ ] **Read the safety page.** Seriously. [Safety and Isolation](02-safety-and-isolation.md) isn't optional.

## What's next?

Once you've done the checklist:

1. [Understand what a cyber range actually is](01-what-is-a-cyber-range.md) (optional but useful)
2. [Read the safety rules](02-safety-and-isolation.md) (not optional)
3. [Build your first range](03-virtualbox-starter-range.md) (the fun part)

You've got this.