# Contributing to Homelabs for Hackers

First up, thanks for being here. Whether you're fixing a typo, adding a lab scenario, or rewriting a whole guide because you found a better way to do something, it all helps. This project is built by people who tinker, and contributions from the community are what keep it useful.

## Ways to contribute

There's no contribution too small. Here's what we're always looking for:

**Fix things.** Found a broken command? A screenshot that doesn't match the current UI? A step that skips something obvious? Open a PR. These fixes matter more than people think.

**Write a lab.** If you've built a cool attack/defend scenario in your own range, turn it into a lab recipe. There's a [template](templates/lab-recipe-template.md) ready to go. Focused, repeatable labs that teach one thing well are worth more than sprawling ones that try to cover everything.

**Improve a guide.** Maybe you followed one of the docs and got stuck somewhere the instructions didn't cover. Add what you learned. If it tripped you up, it'll trip someone else up too.

**Add alternative approaches.** The guides tend to pick one path and run with it. If you've done the same thing a different way (different distro, different tool, different architecture), that's valuable. Add it as a section or a companion doc.

**Report issues.** Couldn't get something working? Something doesn't make sense? Open an issue. Describe what you tried, what happened, and what you expected. No question is too basic here.

## Before you start

Have a look at the open issues to see if someone's already working on what you're thinking. If you're planning something big (a new guide, a major rewrite), open an issue first so we can chat about it. Saves everyone time if we're aligned before you write 2,000 words.

## Style guide

The docs in this repo try to carry a particular voice. It's conversational but not sloppy. Think "explaining something to a friend who's keen to learn rather than a post on LinkedIn.

A few things to keep in mind:
- **Tone.** Write like you're talking to someone. If a sentence sounds weird when you say it out loud, rewrite it. Avoid corporate speak, marketing fluff, and unnecessary jargon. If you must use a technical term, explain it the first time.
- **Language.** This is written in Australian English throughout. That means "virtualisation" not "virtualization", "colour" not "color", "defence" not "defense", "licence" (noun) not "license." Your spellchecker will fight you on this if you're using different settings.
- **Formatting.** Keep markdown clean and readable in source. Use code blocks for anything the reader needs to type or run. Use tables sparingly and only when they genuinely help.
- **Accuracy over cleverness.** If something is complicated, say so. Don't oversimplify to the point of being wrong. It's fine to say "this is a bit fiddly" and then walk through it carefully.
- **Safety first.** If your contribution involves network configuration, VM setup, or anything that could accidentally expose vulnerable machines, include explicit isolation warnings. We never assume the reader knows about the risks.

## Writing a lab recipe

Labs follow a consistent structure so people know what to expect. Use the [lab recipe template](templates/lab-recipe-template.md) as your starting point.

Good labs are:

- **Focused.** One concept or technique per lab. "Learn SQL injection against DVWA" is good. "Learn all of web application hacking" is not a lab, it's a course.
- **Repeatable.** Clear prerequisites, explicit steps, expected outputs. Someone following your lab on a fresh range should get the same results you did.
- **Resettable.** Tell people how to get back to a clean state. Snapshot instructions, service restarts, whatever it takes.
- **Educational.** Explain the "why" alongside the "how." If you're running a command, tell the reader what it does and why you chose it over alternatives.

Include a difficulty label (🟢 Beginner, 🟡 Intermediate, 🔴 Advanced) and an estimated time.

## Submitting your contribution

1. Fork the repo
2. Create a branch with a descriptive name (`fix/gns3-qemu-typo`, `lab/basic-sql-injection`, `docs/proxmox-zfs-guide`)
3. Make your changes
4. Test everything you've written. If it's a guide, follow your own steps on a clean setup. If it's a lab, run it
5. Submit a PR with a clear description of what you've changed and why

## PR expectations
- **We'll review promptly.** Most PRs get a first look within a few days. Bigger contributions might take a bit longer.
- **We'll give honest feedback.** If something needs work, we'll tell you specifically what and why. It's not personal. The goal is to make the content as useful as possible.
- **Maintainers may edit for consistency.** Small tweaks to match the style guide, fix spelling, or adjust formatting might happen during merge. We'll note anything significant.

## Code of conduct

Be decent. Help people learn. Don't gatekeep. Don't be a jerk. If someone asks a question you think is obvious, remember you didn't know it once either.

This project exists to make cybersecurity and cyber ranges more accessible. Act accordingly.

## Questions?

Open an issue, start a discussion, or just submit the PR and we'll figure it out together.

---

<sup>**A note on AI use in this project.** Parts of this repo were reviewed by, amended and drafted with the assistance of LLM's. Some files including guides, lab content, and documentation (including this file) were written collaboratively between the maintainer and an LLM, with the maintainer providing the technical information, architecture decisions, and review. AI was used as a writing, review and structuring tool, not as a substitute for hands-on knowledge. **All technical content** has been written by the maintainer. Contributors are welcome to use AI tools in their own contributions, but you must review and test everything thoroughly before submitting. If a command came from an LLM and you haven't run it yourself, don't submit it!</sup>