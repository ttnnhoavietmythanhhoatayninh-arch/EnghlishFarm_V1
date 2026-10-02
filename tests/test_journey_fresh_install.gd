extends SceneTree

const State=preload("res://game/scripts/journey_state.gd")
const Saves=preload("res://game/scripts/journey_save_manager.gd")
const Store=preload("res://game/scripts/progress_store.gd")

const LEGACY_TEST="user://test_fresh_machine_v3.json"

func _initialize()->void:
 call_deferred("run")

func run()->void:
 # A distributed build must never contain a user's local progress.
 assert(not FileAccess.file_exists("res://englishfarm_journey_v3.json"))
 assert(not FileAccess.file_exists("res://saves/englishfarm_v4/autosave.json"))
 assert(not FileAccess.file_exists("res://saves/englishfarm_v4/slot_1.json"))
 assert(not FileAccess.file_exists("res://saves/englishfarm_v4/slot_2.json"))
 assert(not FileAccess.file_exists("res://saves/englishfarm_v4/slot_3.json"))

 # Simulate a completely new computer.
 Saves.remove_all_v4()
 Store.remove_save_family(LEGACY_TEST)
 if FileAccess.file_exists(Saves.MIGRATION_MARKER):
  DirAccess.remove_absolute(ProjectSettings.globalize_path(Saves.MIGRATION_MARKER))

 var no_auto:=Saves.load_autosave_state(State)
 assert(not bool(no_auto.get("ok",false)))
 var no_legacy:=Saves.migrate_v3(LEGACY_TEST,State)
 assert(not bool(no_legacy.get("ok",false)))
 assert(str(no_legacy.get("error",""))=="no_legacy")

 var fresh:=State.new()
 assert(fresh.level==1)
 assert(not fresh.difficulty_chosen)
 assert(not fresh.onboarded)

 # Simulate a computer that has already played: its local progress must survive.
 var saved:=State.new()
 assert(saved.choose_difficulty("hard"))
 saved.onboarded=true
 saved.cards=42
 saved.powers=5
 var ctx={
  "world_player_position":Vector2(700,1100),
  "current_room":"",
  "room_player_position":Vector2(640,500),
  "return_world_position":Vector2(700,1100)
 }
 assert(Saves.write_autosave(saved.to_dict(),ctx,222222))
 assert(Saves.write_slot(1,saved.to_dict(),ctx,222223))

 var restored:=Saves.load_autosave_state(State)
 assert(bool(restored.get("ok",false)))
 assert(restored.state.level==saved.level)
 assert(restored.state.difficulty=="hard")
 assert(restored.state.cards==42)
 assert(restored.state.powers==5)
 assert(restored.state.onboarded)

 var slot:=Saves.load_slot_state(1,State)
 assert(bool(slot.get("ok",false)))
 assert(slot.state.cards==42)

 # Cleanup test-only local data.
 Saves.remove_all_v4()
 Store.remove_save_family(LEGACY_TEST)
 if FileAccess.file_exists(Saves.MIGRATION_MARKER):
  DirAccess.remove_absolute(ProjectSettings.globalize_path(Saves.MIGRATION_MARKER))

 print("JOURNEY_FRESH_INSTALL_PASSED")
 quit()
