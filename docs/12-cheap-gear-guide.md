# Cheap Gear Guide

You don't need new hardware to run a solid cyber range. Second-hand business desktops are everywhere, they're cheap, and they're perfect for this. Here's what to look for.

> **Note:** I have attempted to make the estimates prices current to March 2026. All price estimated are for AUD $.

## What to look for

### RAM ceiling matters most

Before buying anything, check the maximum RAM the motherboard supports. A $50 desktop with a 16 GB ceiling is less useful than a $70 desktop with a 64 GB ceiling.

Check the manufacturer's specs. Search "MODEL NUMBER max ram" and you'll usually find the answer.

**Good:** 32 GB or higher max RAM

**Acceptable:** 16 GB max (fine for starting out)

**Avoid:** 8 GB max (too limiting if the only machine in your range)

### SSD is non-negotiable

If the machine has a spinning disk, budget for an SSD. VM performance on spinning rust is painful. A cheap 500 GB SATA SSD ($90 to $120) transforms the experience.

Check the machine has:
- SATA ports (almost all do), or
- M.2 slot (newer machines, faster SSDs)

### CPU generation

Older CPUs work but have drawbacks:
- Less efficient (higher power bills, more heat)
- Missing some virtualisation features
- Potentially no longer receiving microcode updates

**Good:** Intel 6th gen (Skylake) or newer, AMD Ryzen

**Acceptable:** Intel 4th/5th gen (Haswell/Broadwell)

**Avoid:** Anything older unless it's basically free

Check virtualisation support: VT-x/VT-d for Intel, AMD-V for AMD. Almost all business desktops from the last decade have this.

### NIC options

For a simple range, the onboard NIC is fine. For proper network segmentation with physical separation, you'll want additional NICs.

Check if the machine has:
- Free PCIe slots (for adding NICs)
- Multiple onboard NICs (some business machines have two)

**Good NIC to buy:** Used Intel dual-port gigabit cards are $20 to $40 and work flawlessly with Linux/Proxmox.

### Physical size

Consider where this will live.

**Small form factor (SFF):** Compact, quiet, limited expansion (often 1 PCIe slot, maybe half-height only)

**Mini tower / desktop:** More expansion slots, still reasonably sized

**Full tower:** Maximum expansion, but takes up space

**Micro PCs (NUCs, etc.):** Very compact, but often zero expansion and limited RAM ceiling

For a dedicated Proxmox box, SFF or mini tower is usually the sweet spot.

## Recommended buy order

If you're upgrading an existing machine or buying something that needs work:

### 1. SSD first (If your machine doesn't have one)

The single biggest improvement. *If the machine doesn't have an SSD, fix this before anything else.*

- 500 GB SATA SSD: $90 to $120
- 1 TB SATA SSD: $170 to $200

### 2. RAM second

After SSD, more RAM means more VMs.

- Check what's installed (some machines come with decent RAM)
- Check what type (DDR3 vs DDR4)
- DDR4 is cheaper and easier to find now
- DDR3 is still available but prices vary

Typical prices:
- 16 GB DDR4: $140 to $200
- 32 GB DDR4: $250 to $350

### 3. NIC third

Only if you need physical network segmentation.

- Intel I350-T2 (dual gigabit): $20 to $40 used
- Intel I350-T4 (quad gigabit): $40 to $60 used

Avoid cheap Realtek cards. They work, but Intel NICs have better driver support. TP-Link cards have also never let me down though.

## Buying tips (AUS Specific)

### Where to buy

**Facebook Marketplace:**
This is the GOAT. Search "HP EliteDesk", "Dell OptiPlex", "Lenovo ThinkCentre". Business machines flood the market as companies upgrade.

**Gumtree:**
Same search terms. Sometimes better deals in regional areas.

**eBay Australia:**
More consistent pricing, buyer protection, but often slightly higher prices.

**You can look around to find ex-lease / refurbished dealers.**
- These often come with short warranties and have been tested.

### What to search for

Good models to look for:

| Brand | Models | Notes |
|-------|--------|-------|
| HP | EliteDesk 800 G2/G3/G4 | Reliable, can have limited expansion |
| Dell | OptiPlex 3040/5040/7040 and newer | Everywhere, well-supported |
| Lenovo | ThinkCentre M710/M720/M910 | Solid build quality |

Avoid consumer-grade machines (HP Pavilion, Dell Inspiron). They're less reliable and have worse expansion options.

### Typical prices (2026)

| Machine | Specs | Expected price |
|---------|-------|----------------|
| i5 6th gen, 8GB, 256GB SSD | Good starter | $150 to $170 |
| i5 7th gen, 16GB, 512GB SSD | Better | $250 to $300 |
| i7 8th gen, 32GB, 1TB SSD | Solid range box | $400 to $600 |

Prices vary. Patience and alerts for good deals pay off.

## Warnings

### Tiny PCs with no expansion

NUC-style machines and ultra-compact desktops often have:
- Soldered RAM (can't upgrade)
- No PCIe slots (can't add NICs)
- Limited cooling (thermal throttling under load)

Fine for a lightweight hypervisor, but limited for growth.

### Loud servers

Enterprise rack servers are tempting. They're cheap, have tons of RAM slots and NIC options.

The catch: they're designed for data centres with industrial cooling. The fans sound like jet engines. Your family/housemates will hate you.

If you go the server route, budget for fan replacement or prepare to put it somewhere the noise won't matter.

### Power bills

Older hardware uses more power. A 10-year-old server running 24/7 adds meaningfully to your electricity bill.

For a range that's on occasionally, it doesn't matter much. For always-on infrastructure, consider newer, more efficient hardware.

### "Needs RAM" or "no HDD" listings

Sometimes good deals, sometimes traps. Calculate total cost including parts you'll need to add. A $50 machine needing $150 in upgrades might not be cheaper than a $180 machine that's ready to go.

## Example builds

### The $150 starter

- Used Dell OptiPlex 3040 SFF (i5-6500, 8GB): ~$100
- Add 500GB SSD: ~$50
- Keep existing 8GB RAM for now

Enough to run Proxmox with 3 to 4 VMs. Upgrade RAM later.

### The $400 solid range

- Used HP EliteDesk 800 G3 (i5-7500, 16GB): ~$180
- Add 1TB SSD: ~$100
- Add another 16GB RAM later: ~$50

Runs 5 to 8 VMs comfortably. Room to grow.

### The $600 serious lab

- Used Dell OptiPlex 7060 (i7-8700, 16GB): ~$300
- Add 1TB NVMe SSD: ~$100
- Upgrade to 64GB RAM: ~$100

Runs a complex range with room for expansion. Handles nested virtualisation reasonably well.

## Don't overthink it

The best range hardware is the hardware you have. Start with your laptop if that's all you've got. Upgrade when the laptop isn't enough.

Second-hand business desktops are plentiful and capable. They don't need to be fancy. They need to run VMs reliably.

Buy the cheapest thing that meets your requirements, spend the savings on an SSD and RAM, and get to learning.

## What's next?

Got hardware sorted? Build your range:

- [Proxmox setup](05-proxmox-upgrade-path.md)
- [Network design](07-network-design-and-segmentation.md)
- [Troubleshooting if things go wrong](13-troubleshooting.md)