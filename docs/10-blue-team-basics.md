# Blue Team Basics

Attacking things is fun. Watching your attacks light up in a SIEM is when you really start learning. This page covers the minimum viable blue team setup: just enough to see what's happening in your range.

## The minimum viable setup

You need two things:

1. **Log collection** - Getting logs from targets, firewalls, and other systems into one place
2. **Visibility** - A way to search, filter, and alert on those logs

That's it. You can expand later, but start here.

## Pick one stack

There are several options. Pick one and learn it well before trying others.

### Option 1: Wazuh (recommended for beginners)

Wazuh is a free, open-source security platform. It does log collection, analysis, and alerting. It's designed for security use cases, so it understands attack patterns out of the box.

**Pros:**
- Security-focused (built-in rules for common attacks)
- Single platform for most needs
- Good documentation
- Free

**Cons:**
- Can be resource-hungry
- Learning curve for custom rules

**Resources:**
- [Wazuh documentation](https://documentation.wazuh.com/)
- [Wazuh quickstart](https://documentation.wazuh.com/current/quickstart.html)

### Option 2: Elastic Stack (ELK)

Elasticsearch, Logstash, Kibana. Very powerful, very flexible. Also very complex.

**Pros:**
- Extremely flexible
- Industry standard
- Great visualisation in Kibana

**Cons:**
- Complex to set up
- Resource hungry
- Security features require more configuration

**Resources:**
- [Elastic documentation](https://www.elastic.co/guide/index.html)

### Option 3: Graylog

Another solid option. Good middle ground between Wazuh and ELK.

**Resources:**
- [Offical Graylog documentation](https://go2docs.graylog.org/current/downloading_and_installing_graylog/installing_graylog.html)

### Recommendation

Start with Wazuh. It's designed for security, is in my experience the easiest to setup, has sensible defaults, and gets you to "seeing attacks" faster. You can always add Elastic or other tools later.

Keeping that in mind this guide does not include install instructions for Elastic or Graylog. They are more of a beast to setup and in my opinion Wazuh just fit's the best for a homelab scenario to start off with.

## Setting up Wazuh (basic)

### Option A: Wazuh OVA (fastest)

Wazuh provides a pre-built virtual machine:

1. Download the OVA from [Wazuh downloads](https://documentation.wazuh.com/current/deployment-options/virtual-machine/virtual-machine.html)
2. Import into VirtualBox or VMware
3. Configure networking to reach your range
4. Access the web UI at `https://WAZUH-IP`

### Option B: Install on Ubuntu

This gives you more control and for the sake of getting the experience, this is the recommend method. This guide does not include specific instructions as they are likely to change between versions - Instead [here](https://documentation.wazuh.com/current/installation-guide/wazuh-server/step-by-step.html) is a link to the official documentation.

### Install agents on targets

On each Windows/Linux target you want to monitor you'll go through steps similar to this : **DO NOT FOLLOW THESE EXACTLY - Follow the offical documentation**.

**Linux:**
```bash
curl -so wazuh-agent.deb https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.7.0-1_amd64.deb
sudo WAZUH_MANAGER='MANAGER-IP' dpkg -i wazuh-agent.deb
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent
```

**Windows:**
Download the MSI from Wazuh, run installer, point at manager IP.

Once agents check in, you'll start seeing logs in the Wazuh dashboard.

## What to collect first

Don't try to collect everything. Start with:

### Windows event logs

These are gold for detecting attacks:

| Windows Security Log | Why |
|-----|-----|
| Security (4624, 4625) | Login success/failure |
| Security (4688) | Process creation |
| Security (4720, 4732) | Account creation, group changes |
| PowerShell (4103, 4104) | Script execution |
| Sysmon (if installed) | Detailed process, network, file activity |

Wazuh collects Windows event logs automatically via the agent.

### Linux auth logs

| Log | Why |
|-----|-----|
| `/var/log/auth.log` | SSH attempts, sudo usage |
| `/var/log/syslog` | General system events |

Wazuh agents collect these by default.

### Firewall logs

Your OPNsense firewall logs all allowed and blocked traffic (if you enabled logging on rules). Send these to Wazuh via syslog:

In OPNsense: System > Settings > Logging / Targets

Add your Wazuh server IP as a syslog destination.

## Five starter detections

Here are concrete things you can detect in your range right now.

### 1. Port scan detection

**What it looks like:** Many connection attempts to different ports in a short time.

**How to generate:** From Kali, run `nmap -sV TARGET-IP`

**What to look for:** Wazuh has built-in rules for scan detection. Check alerts for "scan" or "reconnaissance".

**OPNsense logs:** You'll see many blocked connections from the same source.

### 2. Brute force detection

**What it looks like:** Many failed login attempts followed by (maybe) a success.

**How to generate:** From Kali:
```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt ssh://TARGET-IP
```
Note that you may have to [unzip rockyou.txt](https://www.geeksforgeeks.org/ethical-hacking/how-to-extract-rockyou-txt-gz-file-in-kali-linux/).

**What to look for:**
- Windows: Event ID 4625 (failed login) repeating, then 4624 (success)
- Linux: "Failed password" in auth.log, then "Accepted password"

Wazuh alerts on brute force patterns automatically.

### 3. Suspicious PowerShell

**What it looks like:** Encoded commands, download cradles, execution policy bypasses.

**How to generate:** On a Windows target, run:
```powershell
powershell -enc BASE64STRING
powershell -ep bypass -c "IEX(command)"
```

**What to look for:** PowerShell script block logging (Event ID 4104) shows the actual commands. Look for `-enc`, `-ep bypass`, `IEX`, `DownloadString`.

### 4. New admin user

**What it looks like:** A user account created and added to an admin group.

**How to generate:** On Windows target:
```cmd
net user hacker Password123! /add
net localgroup Administrators hacker /add
```

**What to look for:**
- Event ID 4720: User account created
- Event ID 4732: Member added to security-enabled local group

These should trigger Wazuh alerts.

### 5. Web application attacks

**What it looks like:** SQL injection attempts, path traversal, XSS payloads in web logs.

**How to generate:** Attack DVWA with sqlmap or manual injection.

**What to look for:** Web server access logs with suspicious patterns: `' OR 1=1`, `../../../`, `<script>`, etc.

If you're logging web server access logs, Wazuh can detect common web attack patterns.

## What good looks like

You've got a working blue team setup when:

1. **You see events.** Logs are flowing into your SIEM.
2. **You can search.** Query for a specific IP, user, or time range.
3. **Alerts fire.** Run an attack, see an alert.
4. **You can investigate.** From an alert, you can pivot to related events and run a full investigation.

### The triage loop

When an alert fires:

1. **Identify:** What triggered it? Source IP, target, user, timestamp.
2. **Context:** What else happened around that time? Before? After?
3. **Assess:** Is this malicious, suspicious, or benign?
4. **Document:** Write a 5-line incident note.

Example note:
```
2024-03-15 14:32 UTC
Alert: Multiple failed SSH logins
Source: 10.10.10.50 (atk-kali-01)
Target: 10.10.20.20 (tgt-ubuntu-01)
Assessment: Expected lab activity (brute force practice)
```

Practising this loop, even on your own attacks, builds the muscle memory for real incident response.

## Scaling up

Once the basics work, consider:

- **Sysmon on Windows** for detailed endpoint telemetry
- **Network tap or span port** for packet capture
- **Threat intelligence feeds** for known-bad indicators
- **Sigma rules** for portable detection logic
- **SOAR integration** for automated response

But that's all future state. Get the basics working first.

## What's next?

With visibility in place:

- [Run lab scenarios and watch them in your SIEM](../labs/README.md)
- [Understand snapshots for quick resets](11-snapshots-and-resets.md)
- [Tune your detection rules as you learn](keep practising)