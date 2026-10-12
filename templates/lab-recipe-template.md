# Lab Recipe Template

Use this template when creating new lab scenarios. Copy it to `/labs/your-lab-name/README.md` and fill in the sections.

---

# [Lab Name]

**Difficulty:** 🟢 Beginner / 🟡 Intermediate / 🔴 Advanced

**Time:** XX minutes

**Focus:** [What skill or concept this lab teaches]

## Goal

[One or two sentences describing what you'll accomplish in this lab. What will you know or be able to do by the end?]

## Prerequisites

- [ ] [What VMs you need]
- [ ] [What network setup is required]
- [ ] [Any tools that must be installed]
- [ ] [Any specific configuration needed]

## Topology

```
[ASCII diagram of the network layout for this lab]

Example:
┌──────────┐         ┌──────────┐
│  Kali    │────────►│  Target  │
│ 10.10.10.10       │ 10.10.10.20
└──────────┘         └──────────┘
```

[Brief explanation of what each component is and how they connect]

## Build steps

### Step 1: [Step name]

[Detailed instructions]

```bash
# Commands if needed
```

### Step 2: [Step name]

[Continue with each setup step]

### Verify setup

[How to confirm everything is ready before starting the scenario]

```bash
# Verification commands
```

## Run the scenario

### Attack step 1: [Step name]

[What to do and why]

```bash
# Commands
```

**What you should see:** [Expected output or result]

### Attack step 2: [Step name]

[Continue with attack steps]

### Success criteria

[How do you know the attack worked?]

## Detection goals

If you have logging/SIEM set up, look for:

| What to find | Where to look | What it indicates |
|--------------|---------------|-------------------|
| [Event/log entry] | [Log source] | [What this tells you] |
| [Event/log entry] | [Log source] | [What this tells you] |

### Sample detection queries

```
[Query syntax for your SIEM, if applicable]
```

## Reset steps

1. [How to reset the target VM]
2. [How to reset any other affected systems]
3. [How to verify the range is back to ready state]

```bash
# Reset commands if applicable
```

## Debrief questions

After completing the lab, consider:

1. [Question about what they learned]
2. [Question about how this applies to real scenarios]
3. [Question about what they'd do differently]
4. [Question about potential defences]

## Portfolio notes

For your portfolio, capture:

- [ ] [Suggested screenshot 1]
- [ ] [Suggested screenshot 2]
- [ ] [What to write up about this lab]

## Further reading

- [Link to relevant documentation]
- [Link to deeper explanations]
- [Related labs to try next]

---

## Template notes (delete this section when using)

**Good labs are:**

- **Focused.** Teach one thing well.
- **Reproducible.** Steps should work consistently.
- **Explained.** Say why, not just what.
- **Resettable.** Easy to return to clean state.

**Writing tips:**

- Test your lab before submitting.
- Include expected output where possible.
- Note common mistakes and how to avoid them.
- Keep commands copy-paste friendly.