# NPC_VISUAL_UPDATE.md

Integrate the supplied EnglishFarm NPC update pack.

Source:
`assets/npc-update/EnglishFarm-NPC-Update/`

Use:
- `characters/npc_<id>.png` as the preferred runtime textures
- `npc_data.json` as mapping source
- `godot/npc_name_tag.gd` or equivalent reusable component

Requirements:
- 7 visibly different NPCs: Noah, Lily, Ben, Mia, Emma, Tom, Clara.
- Do not change Momo.
- Name is displayed above each NPC head.
- No permanent name box behind the floating name.
- Default visible screen font size about 18 px, bold/readable, dark outline 4–5 px.
- Use the per-NPC `name_color` in npc_data.json.
- Keep name centered with ~6 px gap above head.
- Name z-order must beat scenery.
- Avoid overlapping name tags when NPCs are close.
- Hide or de-duplicate the floating name during dialogue if dialogue UI already names the speaker.
- Preserve click interaction, E interaction, quest state, relationships and saves.
- Texture filtering must match pixel-art presentation.
- Ensure no magenta fringe.

Do not bake NPCs into room/background images.
