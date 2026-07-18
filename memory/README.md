# memory/ — the substrate seed

This is the part that compounds (principle 5). A model has no memory of you; this folder is where the system keeps what it learns, so every session starts smarter than the last.

Copy this folder onto the box (Step 4) and point the filesystem MCP server at it. Then wire the loop: the agent **writes** a note when something is decided or learned, and **reads** relevant notes when a session starts.

## Layout

```
memory/
├─ README.md                        # this file
└─ decisions/
   └─ 0000-decision-template.md     # copy this for each real decision
```

Start with **decisions**. They're the highest-value thing to record: what you chose, why, and what you rejected. An agent that can read your past decisions stops re-litigating settled questions.

You can grow this later — daily notes, project notes, a knowledge base with embeddings — but it all elaborates this one loop. Start with plain Markdown. Your real notes are git-ignored by default (see `.gitignore`); only this README and the template are tracked.

Prefer a nicer human view? Open this folder as an [Obsidian](https://obsidian.md) vault.
