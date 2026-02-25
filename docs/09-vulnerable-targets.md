# Vulnerable Targets

These are the machines you practice breaking into. Intentionally vulnerable, legally hackable (on your own isolated network), and designed to teach specific skills.

## Rules of engagement

Before we list targets: the rules.

1. **Isolated networks only.** These targets have known vulnerabilities. On the internet, they'd be compromised in minutes. Keep them on host-only or internal networks with no route out.

2. **Your network, your targets.** Only attack targets you own or have explicit permission to test. The targets in this guide are designed to be attacked, but only in your lab.

3. **Snapshot before deploying.** Targets get messy during attacks. Snapshot clean states so you can reset quickly.

4. **Treat them as compromised.** Don't put real credentials or sensitive data on target VMs. Assume attackers (including future-you) will access everything.

## Safe targets list

These are well-known, intentionally vulnerable systems designed for learning.

### Web application targets

| Target | What it teaches | Format |
|--------|-----------------|--------|
| [DVWA](https://github.com/digininja/DVWA) | SQL injection, XSS, CSRF, file inclusion | PHP app (Docker or manual) |
| [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) | Modern web app vulns, OWASP Top 10 | Node.js (Docker) |
| [bWAPP](http://www.itsecgames.com/) | 100+ web vulnerabilities | PHP app |
| [WebGoat](https://owasp.org/www-project-webgoat/) | Web security lessons with hints | Java app |
| [HackTheBox Starting Point](https://www.hackthebox.com/) | Guided web and network challenges | Online (free tier) |

### Full VM targets

| Target | What it teaches | Format |
|--------|-----------------|--------|
| [Metasploitable 2](https://sourceforge.net/projects/metasploitable/) | Classic Linux vulnerabilities | VM image |
| [Metasploitable 3](https://github.com/rapid7/metasploitable3) | Windows and Linux, more modern | Vagrant build |
| [VulnHub](https://www.vulnhub.com/) | Hundreds of community VMs | VM images |
| [DVWA](https://github.com/digininja/DVWA) | Web app testing | PHP on any LAMP stack |

### Windows targets

| Target | What it teaches | Format |
|--------|-----------------|--------|
| [Windows Evaluation ISOs](https://www.microsoft.com/en-us/evalcenter/) | Real Windows, 90-day trial | ISO |
| [Yourfirewall Windows VMs](https://yourfirewall.io/) | Pre-configured vulnerable Windows | VM images |
| [YOURLS](https://yourls.org/) | URL shortener with known vulns | PHP app |

For Windows, the easiest approach is grabbing evaluation ISOs from Microsoft, installing them, then intentionally weakening them (enable SMBv1, create weak passwords, install vulnerable services).

## Deploying targets quickly

### Docker (fastest for web apps)

If Docker is installed on a Linux VM:

```bash
# DVWA
docker run -d -p 80:80 --name dvwa vulnerables/web-dvwa

# Juice Shop
docker run -d -p 3000:3000 --name juiceshop bkimminich/juice-shop

# WebGoat
docker run -d -p 8080:8080 --name webgoat webgoat/webgoat
```

Access via browser: `http://TARGET-IP:PORT`

Docker is great for quickly spinning up multiple web app targets without managing full VMs for each.

### OVA imports (full VMs)

Most VulnHub and similar targets come as OVA files.

**VirtualBox:**
File > Import Appliance > Select OVA > Import

**Proxmox:**
```bash
# Extract OVA
tar -xvf target.ova

# Convert VMDK to qcow2
qemu-img convert -f vmdk -O qcow2 target.vmdk target.qcow2

# Create VM in UI, then import disk
qm importdisk VMID target.qcow2 local-lvm
```

### Manual builds

Sometimes you want to build a target from scratch:

1. Install a base OS (Ubuntu Server is easy)
2. Install the vulnerable application
3. Configure weak credentials
4. Snapshot

This teaches you how services work, which helps when you're exploiting them.

## Verification: Is the target reachable?

After deploying, verify from your attacker VM:

```bash
# Can you reach it?
ping TARGET-IP

# What services are running?
nmap -sV TARGET-IP

# For web apps, can you browse to it?
curl http://TARGET-IP:PORT
```

If Nmap shows open ports matching what you deployed, you're good.

### Common issues

**Target not pingable:**
- Check it's on the same network as your attacker
- Check the target has an IP (might need to log in and configure)
- Check no firewall is blocking (some targets have host firewalls)

**Services not showing:**
- Service might not be started. Log into the target and check.
- Service might be on a non-default port

**Can't browse web app:**
- Check port number
- Check the service is actually running
- Try curl from command line to isolate browser issues

## Reset plan

Targets get messy. You'll create files, modify configs, maybe crash services. You need a quick way to reset.

### Option 1: Snapshots

Snapshot clean state after deployment. Revert when done.

**VirtualBox:** Machine > Restore Snapshot

**Proxmox:** Snapshots tab > Rollback

### Option 2: Rebuild from script

For Docker targets:
```bash
docker stop dvwa && docker rm dvwa
docker run -d -p 80:80 --name dvwa vulnerables/web-dvwa
```

For VMs, keep the OVA and re-import. Or maintain a clone that stays clean.

### Option 3: Linked clones

VirtualBox and Proxmox both support linked clones from a snapshot. Deploy a clean target, snapshot it, create linked clones. Attack the clone, delete it, create a new one. The base stays clean.

## Target ideas for specific skills

| Skill to practice | Target suggestion |
|-------------------|-------------------|
| Network scanning | Any VM with multiple services |
| Web app testing | DVWA, Juice Shop |
| SQL injection | DVWA, SQLi-labs |
| Password attacks | Any with SSH/RDP and weak creds |
| Privilege escalation | VulnHub boxes designed for it |
| Active Directory | Build your own AD lab (separate guide needed) |
| Exploit development | Metasploitable, specific CVE targets |

## Don't hoard targets

It's tempting to download 50 VulnHub VMs "for later." Resist this. Deploy one target, learn from it thoroughly, then move on. A focused lab beats a cluttered one!

You can always download more when you need them. (Do as I say, not as I do)

## What's next?

With targets deployed:

- [Start attacking from your attacker VM](08-attacker-vm.md)
- [Set up detection to watch your attacks](10-blue-team-basics.md)
- [Run structured lab scenarios](../labs/README.md)