extends SceneTree

const State=preload("res://game/scripts/journey_state.gd")
const Saves=preload("res://game/scripts/journey_save_manager.gd")
const Store=preload("res://game/scripts/progress_store.gd")

func _initialize()->void:
 call_deferred("run")

func run()->void:
 Saves.remove_all_v4()
 if FileAccess.file_exists(Saves.MIGRATION_MARKER):
  DirAccess.remove_absolute(ProjectSettings.globalize_path(Saves.MIGRATION_MARKER))
 var s=State.new()
 assert(s.choose_difficulty("normal"))
 s.onboarded=true
 s.tutorial_index=5
 s.cards=17
 s.powers=3
 s.letter_draft="Dear Emma, this draft must survive a save round trip."
 s.record_letter("First sent letter",123400)
 var ctx={
  "world_player_position":Vector2(900,1200),
  "current_room":"emma",
  "room_player_position":Vector2(620,490),
  "return_world_position":Vector2(900,1200)
 }
 assert(Saves.write_autosave(s.to_dict(),ctx,123456))
 assert(Saves.write_slot(1,s.to_dict(),ctx,123457))
 var loaded:=Saves.load_slot_state(1,State)
 assert(bool(loaded.get("ok",false)))
 var t=loaded.state
 assert(t.cards==17 and t.powers==3)
 assert(t.onboarded and t.tutorial_index==5)
 assert(t.letter_draft==s.letter_draft)
 assert(t.letter_history.size()==1)
 assert(str(t.letter_history[0].text)=="First sent letter")
 assert(str(loaded.context.current_room)=="emma")
 assert(Saves.json_to_vec(loaded.context.room_player_position)==Vector2(620,490))

 # Independent manual slots must not overwrite each other.
 s.cards=99
 assert(Saves.write_slot(2,s.to_dict(),ctx,123458))
 var slot1:=Saves.load_slot_state(1,State)
 var slot2:=Saves.load_slot_state(2,State)
 assert(slot1.state.cards==17)
 assert(slot2.state.cards==99)

 # A broken primary file must recover from its validated .bak.
 s.cards=77
 assert(Saves.write_slot(1,s.to_dict(),ctx,123459))
 var f:=FileAccess.open(Saves.slot_path(1),FileAccess.WRITE)
 assert(f!=null)
 f.store_string("{broken json")
 f.close()
 var recovered:=Saves.load_slot_state(1,State)
 assert(bool(recovered.get("ok",false)))
 assert(recovered.state.cards==17)

 # Future/unknown schema is rejected without manufacturing a blank state.
 var bad:=Saves.make_envelope("slot_3",s.to_dict(),ctx,123460)
 bad.schema_version=999
 assert(Store.write_save(Saves.slot_path(3),bad))
 var rejected:=Saves.load_slot_state(3,State)
 assert(not bool(rejected.get("ok",false)))

 # Portable export/import validates the same envelope before replacing live state.
 var export_path:="user://test_englishfarm_export.json"
 assert(Saves.export_current(export_path,s.to_dict(),ctx,123500))
 var imported:=Saves.import_state(export_path,State)
 assert(bool(imported.get("ok",false)))
 assert(imported.state.cards==77)
 assert(str(imported.context.current_room)=="emma")
 Store.remove_save_family(export_path)

 # V3 migration keeps the original and creates a verified V4 autosave.
 var legacy_path:="user://test_journey_v3_migration.json"
 var legacy=State.new()
 legacy.choose_difficulty("hard")
 legacy.onboarded=true
 legacy.cards=31
 legacy.letter_draft="Legacy letter"
 assert(Store.write_save(legacy_path,legacy.to_dict()))
 Saves.remove_autosave()
 var migrated:=Saves.migrate_v3(legacy_path,State)
 assert(bool(migrated.get("ok",false)))
 assert(FileAccess.file_exists(legacy_path))
 assert(migrated.state.cards==31 and migrated.state.difficulty=="hard")
 assert(migrated.state.letter_draft=="Legacy letter")
 assert(FileAccess.file_exists(Saves.MIGRATION_MARKER))
 Saves.remove_autosave()
 var repeated:=Saves.migrate_v3(legacy_path,State)
 assert(not bool(repeated.get("ok",false)))
 assert(str(repeated.get("error",""))=="already_migrated")

 Store.remove_save_family(legacy_path)
 Saves.remove_all_v4()
 if FileAccess.file_exists(Saves.MIGRATION_MARKER):
  DirAccess.remove_absolute(ProjectSettings.globalize_path(Saves.MIGRATION_MARKER))
 print("JOURNEY_SAVE_V4_PASSED")
 quit()
