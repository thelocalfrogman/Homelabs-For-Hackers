# What is a Cyber Range?

A cyber range is an isolated environment where you can practice attacking and defending computer systems without any real-world consequences. Think of it as a flight simulator for security work.

## The core loop

Everything in a cyber range follows the same pattern:

1. **Build** a network with attackers, targets, and maybe some defensive tools
2. **Attack** the targets using real techniques
3. **Defend** by detecting and responding to those attacks (or analysing what happened)
4. **Reset** everything back to a known state
5. **Repeat** with a different scenario or technique

The magic is in the reset. Unlike production environments where you're terrified of breaking things, a range is designed to be broken. Snapshot, attack, learn, revert. Do it again.

## Example scenarios

Here's what you might actually do in a range:

**Scenario: Network reconnaissance**
You spin up three VMs on an isolated network. From your Kali box, you run Nmap scans against the targets. You see what ports are open, what services are running. Then you check your logging VM to see what those scans looked like from the defender's perspective.

**Scenario: Web application attacks**
You deploy a vulnerable web app ([DVWA](https://github.com/digininja/DVWA), [Juice Shop](https://owasp.org/www-project-juice-shop/), etc.) and attack it. SQL injection, XSS, authentication bypass. Meanwhile, your firewall or SIEM is logging HTTP requests, and you learn what malicious traffic patterns look like.

**Scenario: Incident response practice**
You give yourself a ["compromised" VM](09-vulnerable-targets.md) and practice investigating. What processes are running? What network connections are active? What's in the logs? You're building the muscle memory for real incidents.

## How is this different from a homelab?

People use "homelab" to mean all sorts of things. Running Plex, self-hosting services, learning Kubernetes. A cyber range is specifically focused on security training.

The key differences:

| Traditional homelab | Cyber range |
|---------------------|-------------|
| Uptime matters | Uptime is irrelevant |
| Stability is good | Instability is the point |
| Exposed services are often purposeful | Exposed services are dangerous |
| You avoid breaking things | You deliberately break things |
| Persistent state | Frequently reset |

There's overlap, of course. Your range might run on the same hardware as your homelab. But the mindset is different. In a range, destruction is a feature.

## What "good" looks like at beginner level

You don't need much to have a functional range. The minimum viable setup:

- **One attacker VM** (Kali or Parrot) with the standard tools
- **One victim VM** (a vulnerable Linux box or Windows machine)
- **One isolated network** connecting them, with no route to your home LAN or the internet

That's it. From there you can run reconnaissance, attempt exploits, practice post-exploitation. Add logging later. Add a firewall later. Add more targets later. But one attacker, one victim, one isolated network is enough to start learning.

## Common myths

**"I need a server rack"**

Nope. A laptop with 16 GB of RAM runs a starter range fine. Plenty of professionals learned on less.

**"I need expensive gear"**

A $200 second-hand desktop with an SSD upgrade will outperform most laptops for this. The [Cheap Gear Guide](12-cheap-gear-guide.md) has specifics.

**"I need to know everything first"**

You learn by building. You'll make mistakes. VMs will break. Configs will be wrong. That's the process. Snapshot before experimenting, and nothing is permanent.

**"I need to replicate an enterprise environment"**

Not at the start. Complexity comes later, if you want it. A simple range teaches you the fundamentals. An overly complex range just means more things to troubleshoot.

**"This is probably illegal"**

Running vulnerable systems on your own isolated network is completely legal. Attacking systems you own is legal. What's illegal is attacking systems you don't own or have permission to test. Keep your range isolated and you're fine.

## Where to next?

Ready to build? Start with the safety rules (please), then dive into your first build:

2. [Safety and Isolation](02-safety-and-isolation.md)
3. [VirtualBox Starter Range](03-virtualbox-starter-range.md)