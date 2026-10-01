# AGENTS.md — EnglishFarm Journey AutoDev

## Project
- Engine: Godot 4.3 + GDScript
- Main scene: `res://game/scenes/Journey.tscn`
- Resolution: 1280x720
- Current legacy save: `user://englishfarm_journey_v3.json`
- NEVER delete or corrupt V3 save data.

## Mission
Continuously improve EnglishFarm according to:
1. GitHub Issues labeled `agent-run`
2. `agent/ROADMAP.md`
3. Explicit workflow task input

## Mandatory order
BUG FIX -> TEST -> FEATURE/ART UPDATE -> TEST -> BUILD -> PR

## Hard rules
- Never push directly to main.
- Always work in an `agent/...` branch.
- Preserve old saves.
- Never remove working gameplay unless requested.
- Every bug fix must add or strengthen a regression test when practical.
- Stop feature work when a relevant test is failing. Repair first.
- Keep UI usable at 1280x720.
- Pixel art uses nearest filtering where appropriate.
- Momo remains the orange cat with blue scarf.
- NPC names appear above the character, not in permanent name text boxes.
- Do not duplicate NPC sprites if unique assets exist.

## Map / collision rules
- Player must never walk through fences, houses, stalls, bushes, water, furniture, counters, shelves, tables or other solid props.
- Every room exit must place Momo on a walkable point.
- Every required NPC must remain reachable at the level where they unlock.
- Prefer a walkmask or explicit obstacle rectangles/polygons.
- Maintain a clear path around doors and quest-critical targets.
- When map artwork changes, update collision/walkmask together.
- Verify indoor and outdoor collision with automated tests and screenshot evidence.

## NPC visual rules
Use `assets/npc-update/EnglishFarm-NPC-Update/`.
NPCs:
- Noah — fisherman
- Lily — teacher
- Ben — carpenter
- Mia — market
- Emma — postwoman
- Tom — farmer
- Clara — banker

Each NPC:
- unique sprite
- readable name above head
- no background box behind name
- dark outline around name
- high z-index
- name must not be hidden by scenery
- interactions and quest logic must remain unchanged

## Verification
Run:
- Godot import/parser check
- existing gameplay tests
- learning tests
- town tests
- journey, journey_ui, journey_layout, journey_rooms, journey_spacing tests
- screenshot capture when visual/map changes
- Windows export

A task is DONE only when relevant checks pass.
