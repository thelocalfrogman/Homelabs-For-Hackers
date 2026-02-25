# Lab Recipes

This is where the range becomes fun. Each lab is a self-contained scenario you can build, run, detect, and reset.

## What is a lab recipe?

A lab recipe is a structured scenario with:

- A clear goal (what you'll practice)
- A topology (what VMs/networks you need)
- Build steps (how to set it up)
- Attack steps (what to do)
- Detection goals (what should show up in logs)
- Reset steps (how to clean up)
- Debrief questions (what to think about afterwards)

You follow the recipe, do the work, then reset and try again or move to the next one.

## How to use recipes

### 1. Check prerequisites

Each recipe lists what you need. Usually an attacker VM, one or more targets, and optionally a logging setup.

### 2. Build the environment

Follow the setup steps. Some recipes use your existing range; others need specific targets deployed.

### 3. Run the scenario

Execute the attack steps. Take your time. Understand what each command does.

### 4. Detect and investigate

If you have logging set up, check what the attack looked like from the defender side. Can you find evidence of the attack in your logs?

### 5. Reset

Revert snapshots, delete temporary files, restore the range to its ready state.

### 6. Debrief

Answer the debrief questions. Think about what you learned, what surprised you, what you'd do differently.

## Difficulty labels

| Label | Meaning |
|-------|---------|
| 🟢 Beginner | New to this, follow along step by step |
| 🟡 Intermediate | Know the basics, less hand-holding |
| 🔴 Advanced | Minimal guidance, figure things out |

## Expected time

Each recipe includes an estimated time. These are rough guides based on having the prerequisites ready. Your first time through will probably take longer.

## Portfolio notes

Building a portfolio? Each lab has suggestions for what to screenshot or document. Showing your work matters for job applications. A screenshot of a successful exploit next to a screenshot of the detection alert is gold.

## Available labs

| Lab | Difficulty | Focus | Time |
|-----|------------|-------|------|
| [Starter Range](starter-range/README.md) | 🟢 Beginner | First scan, first log entry | 30 min |
| [Web App Range](webapp-range/README.md) | 🟢 Beginner | Web attacks and HTTP logging | 45 min |
| [Windows Basics](windows-basics/README.md) | 🟢 Beginner | Windows events and local recon | 45 min |

More labs will be added. Want to contribute one? See the [template](../templates/lab-recipe-template.md) and [contributing guide](../CONTRIBUTING.md).

## Creating your own labs

Use the [lab recipe template](../templates/lab-recipe-template.md) as a starting point. The structure helps you think through what you're trying to teach and makes it easier for others to follow.

Good labs are:

- **Focused.** One concept or skill per lab.
- **Repeatable.** Clear steps that work consistently.
- **Resettable.** Easy to return to a clean state.
- **Educational.** Explain why, not just what.

## What's next?

Pick a lab and dive in:

- [Starter Range](starter-range/README.md) if you're just getting started
- [Web App Range](webapp-range/README.md) for web application testing
- [Windows Basics](windows-basics/README.md) for Windows-focused practice