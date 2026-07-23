# "Da L00T Heist" — Solo Dev, 4 Hrs/Day Edition (16 Total Working Hours)

**Dev:** 1 person, ~4 hrs/day committed, agentic engineering
**Jam window:** 96 hours (4 calendar days), but your actual working budget is **16 hours total** — that's the number every decision below is built around, not the 96.

This is a real constraint, not a soft one: 16 hours is closer to a solid weekend hackday than a jam. The previous plan assumed something like 20+ hrs/day of availability; this one assumes the opposite end. The fix isn't "work faster" — it's cut scope harder, upfront, and lean on the agent to close the gap on implementation speed so your 4 hours go toward direction/review/design, not typing.

---

## 1. Core Loop (unchanged, still the right game)

Enter with 20 energy → each move costs 1 → obstacles block paths → tools bypass obstacles and grant energy back → every 5 moves a tool spawns → guards wander randomly and must be avoided → grab the loot, reach the exit, before energy hits 0 or a guard catches you.

The design itself doesn't need to shrink — it's already simple. What shrinks is **level count and polish**, not the core mechanic.

---

## 2. Locked Design Decisions (same as before, no time to re-litigate)

| Question | Decision |
|---|---|
| Blocked move (no valid tool) | Costs 1 energy, no move happens |
| Tool bypass rule | Tier-N tool bypasses any obstacle strength ≤ N |
| Reward formula | Energy gained = (tool's cost)² |
| Inventory cap | None |
| Tool spawn tier | Weighted toward low tiers (~35/25/20/12/8%) |
| Guard move chance per turn | 65% per guard, per player move |
| Catch condition | Same-tile only |

---

## 3. The Real Change: Scope

**Cut from 3 levels to 2 (Easy, Hard) — drop Medium entirely.** Two well-tuned levels beat three rushed ones, and "Easy" + "Hard" alone still demonstrates the full mechanic (tools, guards, energy tension) — a Medium level adds judging variety but not new systems, so it's pure content cost with no design payoff. If you finish early, Medium is the first thing to add back, not a launch requirement.

| Parameter | Easy | Hard |
|---|---|---|
| Grid size | ~9×9 | ~13×13 |
| Obstacles | 4-5, strength 1-2 | 8-10, strength 2-5 |
| Guards | 1 | 3 |
| Starting tool | 1 tier-2 visible near start | 0 |

Smaller than your earlier specs on purpose — a 13×13 hard hand-authored maze is a lot faster to build and playtest than 18×18, and still reads as "hard" with more guards and higher-strength obstacles doing the work rather than sheer size.

### Revised Scope Tiers
| Tier | Item |
|---|---|
| Must | Movement/energy loop |
| Must | Tools + obstacles + reward formula |
| Must | Guards + catch condition |
| Must | 2 levels (Easy, Hard) |
| Must | Win/lose state (can be a text label, not a designed screen) |
| Should | Real win/lose screens, HUD polish, tool-spawn indicator |
| Should | Audio |
| Cut-first | Medium level |
| Cut-first | Guard "notices player" AI |
| Cut-first | Story/dialogue, settings menu |

If you're behind pace at any check-in below, cut from the bottom up — don't compress the Must tier to make room for polish.

---

## 4. Agentic Workflow — Where Your 4 Hours Actually Go

With 4 hrs/day, your time is too scarce to spend on boilerplate the agent can produce faster than you can type it. The expert file matters most here — it's what turns "4 hours" into "4 hours of design/review" instead of "4 hours of re-explaining conventions to a fresh agent session."

### 4.1 Expert File (write this in the first 30 minutes of Day 1 — non-negotiable)

```
# Expert File: Da L00T Heist (Solo, 4hr/day Build)

## Conventions
- Godot 4, GDScript, top-down 2D, grid-based movement only
- All balance numbers (energy costs, reward formula, spawn weights, guard move %)
  live in one autoload: Balance.gd
- snake_case functions/vars, PascalCase nodes/classes
- 2 levels only, data-driven (.tres Resources), not hardcoded scenes

## Core Data Model
- Grid: Dictionary<Vector2i, TileData>
- TileData: type (floor/wall/obstacle/loot/exit), obstacle_strength (0 if n/a)
- Tool: tier, cost, bypass_threshold
- PlayerState: energy, inventory[], position, move_count

## Turn Resolution Order
1. Read input direction
2. Validate target tile
3. Obstacle + no valid tool → cost 1 energy, no move
4. Obstacle + valid tool → consume tool, clear obstacle, grant reward, move, cost 1 energy
5. Clear tile → move, cost 1 energy
6. move_count += 1; every 5th move → spawn tool at random open tile
7. Each guard: 65% chance, move 1 tile, random valid direction
8. Check loss: guard on player tile, or energy <= 0
9. Check win: has_loot && on exit tile

## Do Not
- Do not implement continuous/physics movement
- Do not let the agent rebalance numbers mid-session without flagging it first
- Do not hardcode level layouts
- Do not scope-creep — if a session's output includes something not asked for
  (extra polish, extra mechanics), strip it before merging; every unplanned
  feature costs review time you don't have
```

### 4.2 Working Method for 4-Hour Sessions
- **Start each session by re-pasting the expert file.** Don't assume context carries over well across a full day's gap.
- **One subsystem per day, not per session** — with only 4 hours, trying to context-switch between two subsystems in one sitting wastes time on re-orientation. Pick the day's one target, build it, review it, stop.
- **Timebox review to ~30-45 min per day**, not an afterthought — a bad merge on Day 1 costs you Day 2 and 3 fixing it, which you can't afford.
- **Don't debug live in the same session as building.** If something's broken and not obvious in 10-15 min, log it and move on — batch fixes into Day 4.

---

## 5. The 16-Hour Plan (4 Days × 4 Hours)

### Day 1 (4 hrs) — Foundation
- 0:00-0:30 — write the expert file, confirm theme fits the concept (it's theme-agnostic, likely just a flavor/naming pass)
- 0:30-3:30 — agent session: grid + movement + energy deduction on an empty test map
- 3:30-4:00 — playtest bare movement/energy pacing, note anything off for later (don't fix now)

### Day 2 (4 hrs) — Tools & Obstacles
- 0:00-0:15 — re-anchor: paste expert file, review Day 1 notes
- 0:15-3:15 — agent session: tools, obstacles, reward formula, spawn timer
- 3:15-4:00 — playtest on scratch map; confirm the "cheap-tools-only run falls just short" tension is present even roughly

### Day 3 (4 hrs) — Guards + Levels
This is the tightest day — guards *and* two levels in 4 hours is ambitious. If guards take the full session, levels slip to Day 4 morning-of and Should-tier polish gets cut instead. Decide that trade now, not mid-session.
- 0:00-0:15 — re-anchor
- 0:15-2:15 — agent session: guard random walk + catch detection, tested on scratch map
- 2:15-3:45 — build Level 1 (Easy) as a real data file
- 3:45-4:00 — quick playtest, note issues

### Day 4 (4 hrs) — Cut-Line Day
By now Must-tier should be: movement, tools, guards, 1 level. If Level 2 (Hard) isn't built yet, it takes priority this session over any Should-tier item.
- 0:00-2:00 — build Level 2 (Hard) if not done; otherwise, work the known-issues list (crashes/softlocks first)
- 2:00-2:45 — win/lose state (text label is acceptable if time's short; real screens only if ahead of pace)
- 2:45-3:30 — export the actual build and test it for real — this cannot slip, a broken export means no submission
- 3:30-4:00 — submit with buffer; keep a saved known-good build from ~3:15 in case anything breaks late

---

## 6. If You Fall Behind

With no slack in this schedule, here's the exact cut order when a day runs long:
1. Drop Should-tier polish (HUD, audio, win/lose screens → plain text) first — always.
2. Drop Level 2 (Hard) down to a smaller/simpler version rather than cutting it entirely — "1.5 levels" (Easy + a shrunk Hard) still demonstrates the full mechanic.
3. Only as a last resort, drop guard "catch" stakes down to a softer fail state (e.g., lose some energy instead of instant loss) if guard collision logic isn't reliable by Day 4 — a working game with slightly softened guard punishment beats a broken submission.
