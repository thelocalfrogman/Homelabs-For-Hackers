# Homelabs for Hackers

A practical guide to building your own cyber range. No rack required. No prior experience assumed. Just a laptop and some curiosity.

## What is this?

A cyber range is your personal playground for learning offensive and defensive security. You build networks, break into things, detect the attacks, then burn it all down and start again. It's how professionals train, and there's no reason you can't have one at home.

This repo walks you through building a range from absolutely nothing. By the end, you'll have an isolated network with attackers, vulnerable targets, and basic detection. You'll be able to run attack scenarios, watch them light up in logs, and reset everything in minutes.

## Who is this for?

- **Students** wanting hands-on experience before (or alongside) certs
- **Career switchers** building a portfolio that shows you can actually do the work
- **Sysadmins** curious about the security side of things
- **CTF players** wanting a persistent lab environment
- **Anyone** who learns by doing rather than just reading

## What will you build?

Starting with just VirtualBox on your laptop, you'll work up to:

- An isolated network that can't touch your home LAN or the internet
- An attacker VM (Kali or Parrot) with the essentials
- Vulnerable targets you can legally hack
- A firewall controlling traffic between segments
- Basic logging and detection so you can see attacks happening
- Repeatable lab scenarios you can run, detect, and reset

## Start here

| Path | Link |
|------|------|
| **Brand new to this?** | [Start Here](docs/00-start-here.md) |
| **Just want the $0 laptop build?** | [VirtualBox Starter Range](docs/03-virtualbox-starter-range.md) |
| **Want to understand the concepts first?** | [What is a Cyber Range?](docs/01-what-is-a-cyber-range.md) |

## Safety warning

This is important, so read it twice.

**Never expose vulnerable machines to the internet.** The targets in this repo are intentionally broken. They will get owned within minutes if exposed. Keep everything on isolated networks. If you're not sure whether something is isolated, assume it isn't and fix that first.

More detail in [Safety and Isolation](docs/02-safety-and-isolation.md).

## Repo structure

```
docs/           # Guides and explanations
labs/           # Ready-to-run scenarios
templates/      # Blank templates for your own labs
```

## Contributing

This repo is beginner friendly. If you've built something cool, fixed a typo, or written a lab scenario, I want it in here!!! See [CONTRIBUTING.md](CONTRIBUTING.md) for the details.

Found a bug or got stuck? 
Reach out to me !
> **Discord:** thelocalfrogman<br>
> **Email:** thelocalfrogman@proton.me<br>
> **LinkedIn:** [linkedin.com/in/georgeferres](https://www.linkedin.com/in/georgeferres/)

No question is too basic.

## Licence

MIT. Use it, fork it, teach with it, build on it!