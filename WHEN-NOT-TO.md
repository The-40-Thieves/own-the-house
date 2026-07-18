# When one box is the wrong answer

A claim with no failure condition is a sales pitch. This design breaks in three places, and you should know exactly where before you rely on it.

### 1. You need uptime guarantees for other people.
One box is one box. When it reboots, everything on it is down, and no clever config changes that. If someone is paying you for an SLA, you need redundancy this design doesn't have. Use it for your own work, prototypes, and internal tooling — not for something with a contractual uptime promise.

### 2. You won't maintain it.
This is the real killer, and the one nobody admits. You are now on call for your own infrastructure, forever. There's no vendor holding it up underneath you. The day you stop patching, backing up, and tending it, it rots — quietly — until the night it fails and you find out how much you'd offloaded to it. Managed services cost money so someone else carries that weight. If you won't carry it yourself, pay them.

### 3. Your workload is GPU-bound around the clock.
Rent-by-the-job wins when the muscle is bursty. If you're training or serving on a card twenty-four hours a day, renting per job costs more than owning, and you should own. Principle 3 is about *idle* GPUs; a card that's always busy is a different economic case.

---

Outside those three, the single box wins on the number that matters — capability for the money — and it wins by a margin most people won't believe until they run it. Build it for what it's good for, and be honest about what it isn't.
