# Safety and Isolation

This page isn't optional. Read it before you build anything.

The targets you'll deploy are intentionally vulnerable. They have known exploits, weak passwords, missing patches. In the wild, these machines get compromised in minutes. Your job is to make absolutely certain they never see the wild.

## Hard rules

**Rule 1: Never expose vulnerable targets to the internet.**

Not even briefly. Not even "just to test something." Automated scanners hit every public IP constantly. A vulnerable box with a public IP will be owned before you finish your coffee.

**Rule 2: Keep your range networks isolated from your home LAN.**

Your range should not be able to reach your NAS, your smart TV, your partner's laptop. If an experiment goes sideways, the blast radius stays inside the range.

**Rule 3: When in doubt, use host-only networking.**

It's the safest default. Machines can talk to each other and to your host, but cannot reach anything else.

**Rule 4: Treat NAT mode as "internet access for updates only."**

When you need to download packages or updates, switch to NAT temporarily, do what you need, then switch back to host-only. Don't leave vulnerable machines on NAT.

## Network modes explained

VirtualBox (and other hypervisors) give you several network modes. Here's what they actually mean:

### Host-only

Your VM can talk to your host machine and to other VMs on the same host-only network. That's it. No internet. No home LAN. This is your default for range work.

```
[VM] <---> [Host-only Network] <---> [Your Host PC]
                    |
                    +---> [Other VMs on same network]
                    
          (No route to internet or home LAN)
```

**Use for:** Almost everything in your range.

### NAT (Network Address Translation)

Your VM can reach the internet through your host. But VMs can't talk to each other (without extra config), and nothing can initiate connections into the VM.

```
[VM] ---> [NAT] ---> [Your Host] ---> [Internet]
         (one way, outbound only)
```

**Use for:** Downloading updates, packages, tools. Temporarily.

### Bridged

Your VM gets an IP on your home network, just like a physical device. It can see everything on your LAN, and your LAN can see it.

```
[VM] <---> [Your Home Router] <---> [All your other devices]
                   |
                   +--> [Internet]
```

**Use for:** Almost never in a range. Maybe for very specific scenarios where you need the VM to appear as a real device. Not for vulnerable targets.

### Internal network

Like host-only, but even your host machine can't reach it. VMs on the same internal network can only talk to each other.

**Use for:** Super isolated segments. Useful when you want a network your host can't accidentally interact with.

## Safe defaults for beginners

When you're starting out:

1. **Create a dedicated host-only network** for your range (VirtualBox lets you create multiple)
2. **Put all your range VMs on that network** by default
3. **Only use NAT when you need internet access**, and switch back when done
4. **Never use bridged mode for vulnerable targets**
5. **Disable the "cable connected" checkbox** on adapters you're not using

## Keeping your home LAN safe

If you're running your range on a laptop that's also connected to your home wifi, host-only networking handles the isolation for you. The range VMs genuinely cannot reach your home network.

If you're building on dedicated hardware and want extra separation:

**Option 1: Separate NIC**

Use one NIC for your home network (or just for internet access via your router) and a different NIC for range traffic. Physically separate networks.

**Option 2: VLAN**

If your home router or switch supports [VLANs](https://en.wikipedia.org/wiki/VLAN), put your range on its own VLAN. Traffic is isolated at the switch level.

**Option 3: Dedicated lab switch**

A cheap [unmanaged switch](https://en.wikipedia.org/wiki/Network_switch#Configuration_options) connecting only your range hardware. No physical connection to your home network. The air gap approach.

For most beginners on a laptop, none of this is necessary. Host-only networking is sufficient. These options are for when you scale up.

## If you mess up

Mistakes happen. Maybe you accidentally bridged a vulnerable VM, or you're not sure if something is isolated. Here's your incident plan:

1. **Power off the VM immediately.** Not graceful shutdown. Power off. Now.

2. **Disconnect the network cable** or disable wifi on the host if you're paranoid.

3. **Check the VM's network settings.** Was it actually bridged? Was it on NAT? Understand what happened.

4. **Check your router's connected devices list.** Did the VM get a DHCP lease on your home network? If yes, that's a problem.

5. **Revert to a snapshot** from before the misconfiguration. If you don't have one, consider rebuilding the VM.

6. **Check for signs of compromise** if the VM was exposed for any length of time. Unexpected processes, network connections, files. When in doubt, nuke it and rebuild.

Most likely nothing bad happened. But the habit of stopping, checking, and reverting is worth building.

## One more time

Keep your vulnerable targets isolated. Use host-only networking. Snapshot before experimenting. When in doubt, power off and check.

Now you can go build things: [VirtualBox Starter Range](03-virtualbox-starter-range.md)