# Network Design and Segmentation

Good network design makes your range easier to use, easier to expand, and more realistic. Bad network design means confusion, troubleshooting headaches, and eventually rebuilding everything.

This page gives you reference architectures and naming schemes you can copy or adapt.

## The reference architecture

Here's a design that scales from beginner to advanced without needing to be rebuilt.

```
                        ┌─────────────────┐
                        │    Internet     │
                        │   (optional)    │
                        └────────┬────────┘
                                 │
                        ┌────────┴────────┐
                        │    OPNsense     │
                        │    Firewall     │
                        └┬───┬───┬───┬───┬┘
                         │   │   │   │   │
         ┌───────────────┘   │   │   │   └───────────────┐
         │                   │   │   │                   │
         ▼                   ▼   │   ▼                   ▼
┌─────────────────┐  ┌──────────┐│┌──────────┐  ┌─────────────────┐
│   Management    │  │ Attacker │││  Target  │  │     Logging     │
│   10.10.0.0/24  │  │ Segment  │││ Segment  │  │   10.10.40.0/24 │
│                 │  │10.10.10.0│││10.10.20.0│  │                 │
│ ┌─────────────┐ │  │          │││          │  │ ┌─────────────┐ │
│ │  Admin PC   │ │  │ ┌──────┐ │││ ┌──────┐ │  │ │   Wazuh /   │ │
│ │  Jump box   │ │  │ │ Kali │ │││ │Target│ │  │ │    SIEM     │ │
│ └─────────────┘ │  │ └──────┘ │││ │  VMs │ │  │ └─────────────┘ │
└─────────────────┘  └──────────┘│└──────────┘  └─────────────────┘
                                 │
                        ┌────────┴────────┐
                        │       DMZ       │
                        │   10.10.30.0/24 │
                        │                 │
                        │   ┌──────────┐  │
                        │   │ Web apps │  │
                        │   │ Services │  │
                        │   └──────────┘  │
                        └─────────────────┘
```

### Segments explained

**Management (10.10.0.0/24)**

Where you administer things from. Your host machine, a jump box, or admin VMs. This segment can reach everything else for management purposes, but nothing else can initiate connections into it.

**Attacker (10.10.10.0/24)**

Where your offensive tools live. Kali, Parrot, any other attack platforms. Can reach target and DMZ segments (because that's the point), but shouldn't reach management directly.

**Target (10.10.20.0/24)**

Vulnerable machines you're practicing against. Windows boxes, Linux servers, intentionally vulnerable VMs. Isolated from everything except what the firewall explicitly allows.

**DMZ (10.10.30.0/24)**

Simulates a demilitarised zone, like public-facing servers in a real network. Web applications, external services. Attackers can reach it. Targets probably shouldn't.

**Logging (10.10.40.0/24)**

Your visibility infrastructure. SIEM, log aggregation, monitoring. Receives logs from everything, initiates connections to nothing. Protected because if attackers compromise your logging, you're blind.

## Example IP plan

Pick a scheme and stick with it.

| Segment | Network | Gateway | DHCP range | Notes |
|---------|---------|---------|------------|-------|
| Management | 10.10.0.0/24 | 10.10.0.1 | .100-.200 | Admin access only |
| Attacker | 10.10.10.0/24 | 10.10.10.1 | .100-.200 | Offensive tools |
| Target | 10.10.20.0/24 | 10.10.20.1 | .100-.200 | Vulnerable systems |
| DMZ | 10.10.30.0/24 | 10.10.30.1 | .100-.200 | Simulated public |
| Logging | 10.10.40.0/24 | 10.10.40.1 | .100-.200 | Monitoring |

The gateway is always `.1` on each network (your firewall). Static IPs for important systems, DHCP for quick testing.

## Naming scheme

Names should tell you what something is at a glance.

**Pattern:** `segment-purpose-number`

| VM name | Segment | Purpose |
|---------|---------|---------|
| `mgmt-jump-01` | Management | Jump box |
| `atk-kali-01` | Attacker | Primary Kali |
| `tgt-ubuntu-01` | Target | Ubuntu target |
| `tgt-win10-01` | Target | Windows 10 target |
| `dmz-dvwa-01` | DMZ | DVWA web app |
| `log-wazuh-01` | Logging | Wazuh manager |

When you're troubleshooting at 2am, you'll appreciate knowing what's what.

## VLANs vs separate physical ports

Two ways to achieve segmentation:

### Separate physical ports / bridges

Each segment has its own physical NIC or virtual bridge with no connection to others. Traffic between segments must go through the firewall.

**Pros:**
- Simple to understand
- True physical separation
- No VLAN configuration needed

**Cons:**
- Needs multiple NICs
- Less flexible

### VLANs

Multiple logical networks share one physical connection, separated by VLAN tags. A VLAN-aware switch and firewall handle the separation.

**Pros:**
- One NIC handles many segments
- More flexible
- Mirrors how real enterprise networks work

**Cons:**
- More complex to configure
- Misconfiguration can leak traffic between VLANs

### Recommendation

Start with separate bridges or host-only networks. It's simpler and mistakes are less dangerous. Move to VLANs when you understand the concepts and want to practice VLAN-based segmentation.

## Growing the design

### Stage 1: Beginner

```
┌──────────────────────────────────────┐
│         Host-only Network            │
│                                      │
│   ┌──────┐              ┌──────┐     │
│   │ Kali │ ◄──────────► │Target│     │
│   └──────┘              └──────┘     │
└──────────────────────────────────────┘
```

Just two VMs on one network. Enough to learn scanning, basic exploitation, and enumeration.

### Stage 2: Add a firewall

```
┌────────────────────────────────────────────────────┐
│                     OPNsense                       │
│   ┌────────────────────┬───────────────────────┐   │
│   │    Attacker Net    │      Target Net       │   │
│   │                    │                       │   │
│   │   ┌──────┐         │        ┌──────┐       │   │
│   │   │ Kali │         │        │Target│       │   │
│   │   └──────┘         │        └──────┘       │   │
│   └────────────────────┴───────────────────────┘   │
└────────────────────────────────────────────────────┘
```

Now you control traffic flow, can log at the firewall, and start to see what "network defence" means.

### Stage 3: Add logging

```
┌─────────────────────────────────────────────────────┐
│                      OPNsense                       │
│   ┌──────────────┬──────────────┬───────────────┐   │
│   │   Attacker   │    Target    │    Logging    │   │
│   │              │              │               │   │
│   │  ┌──────┐    │   ┌──────┐   │   ┌───────┐   │   │
│   │  │ Kali │    │   │Target│   │   │ Wazuh │   │   │
│   │  └──────┘    │   └──────┘   │   └───────┘   │   │
│   └──────────────┴──────────────┴───────────────┘   │
└─────────────────────────────────────────────────────┘
```

Now you can run attacks and watch them light up in your SIEM. This is where the learning accelerates.

### Stage 4: Full architecture

The reference diagram at the top. Multiple segments, DMZ, proper management isolation. You're now running something that resembles a real network.

## Don't make it fragile

Some tips from painful experience:

**Document your IP scheme.** Keep a text file or spreadsheet. Update it when you add machines.

**Use templates and clones.** Build a base image, snapshot it, clone from there. Don't reinstall from scratch every time.

**One thing per VM.** Resist the urge to cram everything onto one machine. When it breaks, you lose everything.

**Test after changes.** Changed a firewall rule? Test that things still work as expected. Five minutes of testing beats hours of debugging.

**Snapshot before experiments.** Always. The habit will save you eventually.

## What's next?

With a network design in mind:

- Build it out: [VirtualBox](03-virtualbox-starter-range.md), [Proxmox](05-proxmox-upgrade-path.md), or [GNS3](04-gns3-intro.md)
- Add a firewall: [OPNsense](06-firewall-opnsense.md)
- Populate it: [Attacker VM](08-attacker-vm.md), [Vulnerable targets](09-vulnerable-targets.md)
- Get visibility: [Blue Team Basics](10-blue-team-basics.md)