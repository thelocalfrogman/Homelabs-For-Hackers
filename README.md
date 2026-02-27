# Homelabs for Hackers

A practical guide to building your own cyber range. No rack required. No prior experience assumed. Just a laptop and some curiosity.

## So what's a cyber range?

Think of it as your own personal playground for learning how to break into things and how to spot when someone's breaking into yours. You build networks, attack them, watch the alerts fire, then burn it all down and do it again. It's how the pros train, and there's absolutely nothing stopping you from having one at home.

This repo walks you through building a range from nothing. By the end you'll have an isolated network with attackers, vulnerable targets, and basic detection. You'll run attack scenarios, watch them light up in your logs, and reset the whole thing in minutes.

## Who's this for?
Anyone who'd rather learn by doing than by reading another textbook!

- **Students** who want real hands-on experience before or alongside certs
- **Career switchers** building a portfolio that proves you can actually do the work
- **Sysadmins** who want to get into the security side
- **CTF players** after a persistent lab that's always there when you need it
- **The curious** who just like pulling things apart to see how they work

If you've ever spun up a VM just to poke at it, you're in the right place.

## What you'll end up with

Starting with nothing but VirtualBox on your laptop, you'll work your way up to:

- An isolated network that can't touch your home LAN or the internet
- An attacker VM (Kali or Parrot) loaded with the essentials
- Vulnerable targets you can legally hack to bits
- A firewall controlling traffic between segments
- Basic logging and detection so you can actually see attacks happening
- Repeatable lab scenarios you can run, detect, and reset

## Start here

| Path | Link |
|------|------|
| **Brand new to all of this?** | [Start Here](docs/00-start-here.md) |
| **Just want the $0 laptop build?** | [VirtualBox Starter Range](docs/03-virtualbox-starter-range.md) |
| **Want to understand the concepts first?** | [What is a Cyber Range?](docs/01-what-is-a-cyber-range.md) |

## Safety warning

This bit matters. Read it twice.

**Never expose vulnerable machines to the internet.** The targets in this repo are intentionally broken. They will get [owned](https://en.wikipedia.org/wiki/Owned_(slang)) within minutes if they're exposed. Keep everything on isolated networks. If you're not sure whether something is isolated, assume it isn't and fix that first.

More detail in [Safety and Isolation](docs/02-safety-and-isolation.md).

## Repo structure

```
docs/           # Guides and explanations
labs/           # Ready-to-run scenarios
templates/      # Blank templates for your own labs
```

## Contributing

This repo is beginner friendly. If you've built something cool, fixed a typo, added an explanation, or written a lab scenario, I want it in here! See [CONTRIBUTING.md](CONTRIBUTING.md) for the details.

Found a bug or got stuck? Come find me:

> **Discord:** thelocalfrogman<br>
> **Email:** georgeferres@proton.me<br>
> **LinkedIn:** [linkedin.com/in/georgeferres](https://www.linkedin.com/in/georgeferres/)

No question is too basic. Seriously.

## Licence

MIT. Use it, fork it, teach with it, build on it.