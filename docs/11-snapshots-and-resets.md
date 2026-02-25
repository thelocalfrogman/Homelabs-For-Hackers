# Snapshots and Resets

A cyber range without snapshots is like a video game without save points. You're going to break things. Snapshots let you break things confidently, knowing you can always roll back.

## Snapshot strategy

Snapshot at milestones, not randomly. Here's a framework that works:

### VirtualBox / VMware snapshot points

| Snapshot name | When to take it | What it captures |
|---------------|-----------------|------------------|
| `01-clean-install` | Right after OS installation | Base OS, nothing else |
| `02-network-configured` | After setting static IP and hostname | Networking ready |
| `03-services-installed` | After installing target services | SSH, web server, etc. |
| `04-lab-ready` | After any lab-specific setup | Ready for scenario |
| `05-pre-experiment` | Before trying something risky | Safety net |

### Proxmox snapshot points

Same concept, but Proxmox handles snapshots differently (they're faster and more efficient).

| Snapshot name | When to take it |
|---------------|-----------------|
| `base` | Clean install |
| `configured` | Network and services set up |
| `scenario-X-ready` | Prepared for specific scenario |
| `checkpoint` | Mid-scenario save (if needed) |

## Taking snapshots

### VirtualBox

**GUI:**
1. Select the VM (can be running or stopped)
2. Machine > Take Snapshot (or Ctrl+Shift+S)
3. Name it clearly
4. Add a description (future you will thank present you)

**Command line:**
```bash
VBoxManage snapshot "VM-Name" take "snapshot-name" --description "What this captures"
```

### Proxmox

**GUI:**
1. Select the VM
2. Go to Snapshots tab
3. Click "Take Snapshot"
4. Name and describe it

**Command line:**
```bash
qm snapshot VMID snapshot-name --description "What this captures"
```

### Tips for good snapshots

- **Name descriptively.** `working-lab-config` beats `snapshot1`.
- **Add descriptions.** Include date and what state the VM is in.
- **Snapshot clean states.** Don't snapshot mid-experiment unless you need that exact state.
- **Snapshot before updates.** `apt upgrade` can break things. Snapshot first.

## Restoring snapshots

### VirtualBox

**GUI:**
1. Select the VM
2. Machine > Snapshots (or click the snapshot icon)
3. Select the snapshot you want
4. Click "Restore"

Note: This discards the current state. If you want to keep it, snapshot first.

**Command line:**
```bash
VBoxManage snapshot "VM-Name" restore "snapshot-name"
```

### Proxmox

**GUI:**
1. Select VM > Snapshots
2. Select snapshot
3. Click "Rollback"

**Command line:**
```bash
qm rollback VMID snapshot-name
```

## Resetting a whole range fast

After a lab scenario, you want to reset everything quickly. Here's how.

### The manual way

Restore each VM's snapshot individually. Fine for 2 to 3 VMs, tedious for more.

### The scripted way (VirtualBox/VMware)

Create a reset script:

```bash
#!/bin/bash
# reset-range.sh

VMS=("range-kali" "range-target-01" "range-target-02")
SNAPSHOT="lab-ready"

for vm in "${VMS[@]}"; do
    echo "Restoring $vm to $SNAPSHOT..."
    VBoxManage controlvm "$vm" poweroff 2>/dev/null
    sleep 2
    VBoxManage snapshot "$vm" restore "$SNAPSHOT"
    VBoxManage startvm "$vm" --type headless
done

echo "Range reset complete."
```

Run it: `./reset-range.sh`

### The scripted way (Proxmox)

```bash
#!/bin/bash
# reset-range.sh

VMS=(100 101 102)  # VM IDs
SNAPSHOT="lab-ready"

for vmid in "${VMS[@]}"; do
    echo "Restoring VM $vmid to $SNAPSHOT..."
    qm stop $vmid 2>/dev/null
    sleep 2
    qm rollback $vmid $SNAPSHOT
    qm start $vmid
done

echo "Range reset complete."
```

### Linked clones for fast resets

Both VirtualBox/VMware and Proxmox support linked clones. The idea:

1. Create a "golden image" VM
2. Snapshot it
3. Create linked clones from that snapshot
4. Attack the clones
5. Delete clones and recreate when needed

Clones share the base disk with the snapshot, so they're fast to create and use less space. Deleting and recreating is often faster than reverting.

## Lab save points

Think of your range progression in stages. Snapshot at each stage.

### Example progression

```
Stage 1: Base installs
├── kali: clean-install
├── ubuntu-target: clean-install
└── opnsense: clean-install

Stage 2: Network configured
├── kali: network-ready
├── ubuntu-target: network-ready
└── opnsense: interfaces-configured

Stage 3: Services ready
├── kali: tools-updated
├── ubuntu-target: ssh-web-installed
└── opnsense: rules-configured

Stage 4: Lab-specific
├── kali: lab01-ready
├── ubuntu-target: lab01-vulnerable
└── opnsense: lab01-rules
```

You can reset to any stage. Want to redo a lab from scratch? Reset to stage 3. Want to try a different network config? Reset to stage 1.

## Common mistakes

### Snapshot sprawl

You keep taking snapshots and never clean up. Eventually you have 47 snapshots per VM, can't remember what any of them are, and you're running low on disk space.

**Fix:** Periodically review and delete snapshots you no longer need. Keep 3 to 5 meaningful ones per VM.

### Forgetting to snapshot before experiments

You try something, it breaks everything, and you have no recent snapshot to restore.

**Fix:** Build the habit. Before any experiment: "Did I snapshot?"

### Snapshots with no description

You have `snap1`, `snap2`, `snap3`. No idea what state any of them represent.

**Fix:** Always add a description. "Clean Kali install, static IP 10.10.10.10, no extra tools" tells you exactly what you're getting.

### Snapshotting while services are mid-transaction

Databases and some services don't like being snapshotted while they're in the middle of writing data. You restore and find corruption.

**Fix:** For important snapshots, cleanly shut down services first, or use application-aware backup tools. For lab VMs, it's usually fine, but be aware.

### Never testing restores

You assume snapshots work. You've never actually tried restoring one.

**Fix:** Test your restore process. Take a snapshot, make a change, restore, verify the change is gone.

## When not to use snapshots

Snapshots aren't backups. They're save points.

- **Long-term preservation:** Use proper backups (Proxmox backup, exported VMs)
- **Moving VMs between hosts:** Export/import, not snapshots
- **Production systems:** (Not that you'd have those in a range, but still)

For a range, snapshots are your primary tool. Just don't confuse them with a backup strategy for things you actually care about.

## What's next?

With snapshots sorted:

- [Run lab scenarios with confidence](../labs/README.md)
- [Troubleshoot when things go wrong](13-troubleshooting.md)
- [Build more complex setups](07-network-design-and-segmentation.md)