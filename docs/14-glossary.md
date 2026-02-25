# Glossary

Quick definitions for terms used throughout this repo. No jargon soup, just enough to understand what we're talking about.

## NAT (Network Address Translation)

A way to let multiple devices share a single public IP address. In virtualisation, NAT mode means your VM can reach the internet through your host machine, but the VM doesn't get its own address on your network. Traffic goes out, but nothing can initiate connections in. Useful for updates, not useful for labs where you need VMs talking to each other.

## Host-only network

A virtual network that exists only between your VMs and your host machine. VMs on a host-only network can communicate with each other and with your host, but cannot reach the internet or your home network. This is your default for range work because it's inherently isolated.

## Bridged network

A network mode where your VM gets an IP address on your real network, just like a physical machine. The VM appears as another device on your LAN. Useful for some scenarios, dangerous for vulnerable targets because they'd be exposed to your home network.

## Internal network

Like host-only, but even your host machine can't reach it. Only VMs attached to the same internal network can communicate. Maximum isolation. Useful when you want network segments that are truly separate.

## VLAN (Virtual LAN)

A way to create multiple logical networks on a single physical network. Traffic is tagged with a VLAN ID, and switches/routers use that tag to keep networks separate. Lets you have "attacker network" and "target network" sharing the same physical cables but logically isolated. More complex than physical separation but more flexible.

## Bridge (network bridge)

In virtualisation (especially Proxmox), a bridge is like a virtual switch. You create a bridge, attach it to a physical NIC (or not), and then connect VMs to that bridge. VMs on the same bridge can communicate. Bridges not attached to a physical NIC are isolated from the outside world.

## DMZ (Demilitarised Zone)

A network segment that sits between your internal network and the internet. In the real world, public-facing servers (web servers, mail servers) live here. They're more exposed than internal systems but still protected from the full internet. In a range, you might have a DMZ segment for targets that simulate public-facing services.

## Snapshot

A point-in-time capture of a VM's state. Includes disk, memory (optionally), and configuration. You can revert to a snapshot to restore the VM to exactly that state. Essential for range work: snapshot before experiments, revert when things break or when you're done with a lab.

## Agent

A piece of software running on a target system that communicates with a central server. In logging/SIEM contexts, an agent collects logs and sends them to your logging server. In other contexts (like Metasploit), an agent is software you've deployed on a compromised system. Context matters.

## SIEM (Security Information and Event Management)

A system that collects, stores, and analyses security logs from across your environment. It correlates events, fires alerts, and gives you visibility into what's happening. Wazuh and Elastic/ELK are common options. In a range, your SIEM is how you see your attacks from the defender's perspective.

## Hypervisor

Software that runs virtual machines. Type 1 hypervisors (Proxmox, ESXi) run directly on hardware. Type 2 hypervisors (VirtualBox, VMware Workstation) run on top of an existing operating system. Both let you create and manage VMs. For a range, either works.

## OVA (Open Virtual Appliance)

A file format for packaging a virtual machine. Contains the disk image and configuration. You can import an OVA into VirtualBox, VMware, or (with conversion) Proxmox. Many vulnerable targets are distributed as OVAs.

## ISO

A disk image file. Typically used for operating system installers. You "mount" an ISO in your VM's virtual CD drive to install an OS. Download ISOs from official sources.

## NIC (Network Interface Card)

The hardware that connects a computer to a network. Your VM has virtual NICs. Your host has physical NICs. When planning network segmentation with physical separation, you need multiple NICs.

## Pentest / Penetration testing

Authorised simulated attacks against a system to find vulnerabilities. "Authorised" is the key word. In your range, you're pentesting your own targets. In the real world, you need written permission.

## CTF (Capture the Flag)

Security competitions where you solve challenges or exploit systems to find hidden "flags" (strings of text that prove you succeeded). Good practice and often fun. VulnHub and HackTheBox are CTF-style platforms.

## Exploit

Code or a technique that takes advantage of a vulnerability to do something the system wasn't meant to allow. Running an exploit against your target is how you test whether the vulnerability is actually exploitable.

## Payload

The code that runs after an exploit succeeds. The exploit gets you in; the payload does what you wanted to do (open a shell, create a user, exfiltrate data, etc.).

## Reverse shell

A connection from a compromised target back to your attacker machine. You run a listener on your attacker, the payload on the target connects back to you. Useful when the target can make outbound connections but you can't reach it directly.

## Bind shell

The opposite of reverse shell. The payload opens a port on the target and waits for you to connect. You initiate the connection. Easier in some ways, but requires the target's port to be reachable.

## Post-exploitation

What you do after initial access. Privilege escalation, persistence, lateral movement, data exfiltration. The initial exploit is just the beginning.

## Privilege escalation

Going from low privileges to higher privileges. "Local privesc" means going from regular user to root/admin on a single system. A common step after initial access.

## Lateral movement

Moving from one compromised system to other systems in the network. You've owned one box, now you use that access to reach others.

## IOC (Indicator of Compromise)

Evidence that a system has been compromised. IP addresses, file hashes, domain names, registry keys, whatever. Defenders look for IOCs in their logs and on their systems.

## TTPs (Tactics, Techniques, and Procedures)

How attackers operate. Tactics are the "why", techniques are the "how", procedures are the specific implementation. MITRE ATT&CK is a framework that catalogues TTPs.

## MITRE ATT&CK

A knowledge base of adversary tactics and techniques. Useful for understanding how attacks work and mapping your detections to known attack patterns. Worth exploring once you have basic detections working.

## Need a term defined?

If something in these guides uses a term that isn't clear, open an issue or PR to add it to this glossary.