# Attacker VM

Your attacker VM is where you run offensive tools. It needs to be functional, not fancy. Here's how to set one up without overthinking it.

## Kali vs Parrot

The two most common choices. Both are Debian-based, both come with security tools preinstalled.

### Kali Linux

The default choice for most people. Maintained by Offensive Security, well-documented, huge community.

**Pros:**
- Most tutorials assume Kali
- Extensive tool collection out of the box
- Regular updates
- Good documentation

**Cons:**
- Can feel bloated (lots of tools you'll never use)
- Resource hungry if you install the full desktop

### Parrot Security

A solid alternative. Slightly lighter than Kali, similar tool set.

**Pros:**
- Lighter resource usage
- Privacy-focused features built in
- Good tool selection
- Looks nice (if that matters to you)

**Cons:**
- Smaller community than Kali
- Some tutorials might not match exactly

### The verdict

**It doesn't matter!** If you can't decide, let me - start with Kali. If for no other reason than it's what most learning resources assume. If you try it and find it too heavy, switch to Parrot. They're similar enough that skills transfer directly.

## What you actually need at the start

Kali and Parrot come with hundreds of tools. You'll use maybe 20 of them regularly. Here's the main ones that matter early on and are fun to play with in labs:

### Reconnaissance

| Tool | Purpose |
|------|---------|
| `nmap` | Network scanning, port discovery, service detection |
| `netcat` / `nc` | Network connections, simple listeners |
| `whois`, `dig`, `nslookup` | DNS and domain info |
| `dirb` / `gobuster` / `feroxbuster` | Web directory enumeration |

### Exploitation

| Tool | Purpose |
|------|---------|
| `metasploit` | Exploit framework |
| `searchsploit` | Local exploit database search |
| `hydra` | Password brute forcing |
| `john` / `hashcat` | Password cracking |
| `sqlmap` | SQL injection automation |

### Web

| Tool | Purpose |
|------|---------|
| `burpsuite` | Web proxy and testing |
| `nikto` | Web server scanner |
| `curl` / `wget` | HTTP requests from command line |

### Utilities

| Tool | Purpose |
|------|---------|
| `python3` | Scripting, running exploits |
| `git` | Pulling tools and repos |
| `vim` / `nano` | Editing files |
| `tmux` / `screen` | Terminal multiplexing |

Everything else you can install when you need it. Don't waste time "setting up" tools you've never heard of and do your best to spend your time in labs learning concepts, not syntax.

## Safety: Keep attacker on range networks only

Your attacker VM should be on your isolated range networks. Not bridged to your home LAN. Not able to reach the internet unless you specifically allow it for updates.

Why? Two reasons:

1. **Accidents happen.** You don't want to accidentally scan your neighbour's network because you misconfigured something.

2. **Isolation works both ways.** If somehow something on your attacker VM gets compromised (unlikely but possible), it can't reach your real network.

In VirtualBox: Use host-only or internal network adapters.

In Proxmox: Use isolated bridges (vmbr1, etc.) not the main bridge.

When you need to update or install packages, temporarily add a NAT adapter, do your updates, then remove it.

## Installation

### VirtualBox / VMware

1. Create a new VM:
   - Name: `range-kali` or `atk-kali-01`
   - Type: Linux
   - Version: Debian (64-bit)
   - RAM: 4096 MB (adjust based on your host)
   - Disk: 60 GB, dynamically allocated

2. Attach the Kali ISO to the CD drive

3. Set network adapter to **Host-only** (your range network)

4. Start and install. Defaults are fine for most options.

5. Post-install: set a static IP that fits your range IP scheme

### Proxmox

1. Upload the Kali ISO to your storage

2. Create VM:
   - Memory: 4096 MB
   - Disk: 60 GB
   - Network: Your isolated bridge (e.g., vmbr1)

3. Install Kali

4. Configure static IP matching your network design

## Snapshot points

Snapshot your attacker VM at these stages:

| Snapshot | Description |
|----------|-------------|
| `clean-install` | Fresh OS install, nothing else |
| `network-configured` | Static IP set, on range network |
| `tools-updated` | After `apt update && apt upgrade` |
| `lab-ready` | Any additional tools installed for a specific lab |

This way you can always roll back to a known good state.

### Taking snapshots

**VirtualBox:**
Machine > Take Snapshot (or Ctrl+Shift+S)

**Proxmox:**
Select VM > Snapshots > Take Snapshot

## Keeping tools updated

When you need to update:

1. Temporarily add a NAT adapter or enable internet access through your firewall
2. Run:
   ```bash
   sudo apt update
   sudo apt upgrade -y
   ```
3. Remove the NAT adapter / disable internet access
4. Snapshot

Don't leave your attacker with internet access during labs. It's not needed and adds unnecessary exposure.

## Adding tools

Most tools install via apt:

```bash
sudo apt install <tool-name>
```

For tools not in the repos, clone from GitHub:

```bash
git clone https://github.com/author/tool-name.git
cd tool-name
# Follow the tool's install instructions
```

Some tips:

- Keep custom tools in a consistent location like `~/tools/`
- Note what you install and why (a simple text file works)
- Snapshot after installing new tools that work

## Don't over-prepare

It's tempting to spend hours "setting up" your attacker VM with every tool imaginable. Resist this.

Install what you need for the lab you're doing. Learn one tool well before adding another. A bloated VM with tools you don't understand is worse than a minimal VM where you know what everything does.

You'll build up your toolkit naturally as you work through labs. That's the process.

## What's next?

With your attacker ready:

- [Deploy some targets to attack](09-vulnerable-targets.md)
- [Set up detection to watch your attacks](10-blue-team-basics.md)
- [Run your first lab scenario](../labs/starter-range/README.md)