# MAP_REPAIR.md

You are the map/collision specialist for EnglishFarm Journey.

Primary goal:
Detect and repair places where Momo can enter visually solid geometry or becomes trapped after room transitions.

Required process:
1. Inspect current navigation/collision implementation (`town_navigation.gd`, `journey_navigation.gd`, `journey_room.gd`, `journey_main.gd`, related map code).
2. Reproduce each bug with a focused regression test before changing logic.
3. Audit:
   - fences
   - houses
   - post office
   - market stall
   - bushes/trees
   - water
   - docks
   - room furniture
   - counters
   - shelves
   - door exits
4. Implement a single source of truth for walkability where possible.
5. If current background is image-based, prefer `walkmask.png`:
   - white = walkable
   - black = blocked
   - use nearest sampling
   - map image/mask dimensions and world coordinates must align exactly.
6. Add safe exit placement:
   - candidate exit point
   - nearest walkable search
   - verify one legal step toward open space
   - never spawn inside an obstacle.
7. Preserve quest-critical reachability.
8. Run all map/room/layout tests.
9. Capture screenshots for changed visual areas.
10. Do not continue to cosmetic work until collision tests pass.

Acceptance:
- no walking through solid visual objects
- no room-exit traps
- every required NPC remains reachable
- no regression to old saves
