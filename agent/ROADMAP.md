# EnglishFarm Autonomous Roadmap

The agent picks the highest unchecked task when no explicit task is provided.

## P0 — Repair first
- [ ] Audit all outdoor collision zones and stop Momo walking through fences/buildings/stalls/bushes/water.
- [ ] Fix room-exit safe spawn for all 8 rooms.
- [ ] Fix Mia door/market exit point.
- [ ] Ensure Noah remains reachable when unlocked at level 3.
- [ ] Make tests fail with a non-zero exit code when behavior is wrong.

## P1 — NPC visual upgrade
- [ ] Replace duplicate NPC art with all 7 unique sprites from `assets/npc-update/`.
- [ ] Add floating name tags above all NPC heads.
- [ ] Prevent name tags from being covered by scenery or colliding visually.
- [ ] Keep click/E interactions and quests intact.

## P2 — V4 room/map polish
- [ ] Integrate V4 room backgrounds without baking Momo/NPC sprites into backgrounds.
- [ ] Add collision to tables, shelves, counters, furniture and room walls.
- [ ] Keep door paths clear.
- [ ] Standardize warm pixel-art lighting and visual scale.

## P3 — Tutorial + save/load
- [ ] Replace onboarding with 10-page V4 tutorial.
- [ ] Add V4 multi-slot save system while preserving V3 migration.
- [ ] Add safe autosave using tmp -> validate -> rename + bak.

## P4 — Continuous polish
- [ ] Inspect latest screenshots for layout/collision/readability problems.
- [ ] Improve the most visible verified issue without breaking gameplay.
