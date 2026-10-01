extends RefCounted

const ProgressStore=preload("res://game/scripts/progress_store.gd")
const ROOT="user://saves/englishfarm_v4"
const AUTOSAVE=ROOT+"/autosave.json"
const SLOT_PATHS={
 1:ROOT+"/slot_1.json",
 2:ROOT+"/slot_2.json",
 3:ROOT+"/slot_3.json"
}
const SCHEMA_VERSION=4
const CONTENT_VERSION="englishfarm-journey-v4"
const MIGRATION_MARKER=ROOT+"/v3_migrated.flag"
const VALID_ROOMS=["","home","tom","lily","mia","emma","ben","clara","noah"]

static func ensure_root()->bool:
 var absolute:=ProjectSettings.globalize_path(ROOT)
 return DirAccess.make_dir_recursive_absolute(absolute)==OK or DirAccess.dir_exists_absolute(absolute)

static func vec_to_json(value:Vector2)->Dictionary:
 return {"x":value.x,"y":value.y}

static func json_to_vec(value:Variant,fallback:=Vector2.ZERO)->Vector2:
 if value is Vector2:
  return value if value.is_finite() else fallback
 if not value is Dictionary:return fallback
 var x=value.get("x",fallback.x)
 var y=value.get("y",fallback.y)
 if not (x is int or x is float) or not (y is int or y is float):return fallback
 var v:=Vector2(float(x),float(y))
 return v if v.is_finite() else fallback

static func normalize_context(context:Dictionary)->Dictionary:
 var room_id:=str(context.get("current_room",""))
 if room_id not in VALID_ROOMS:room_id=""
 return {
  "world_player_position":vec_to_json(json_to_vec(context.get("world_player_position",{}),Vector2(400,1380))),
  "current_room":room_id,
  "room_player_position":vec_to_json(json_to_vec(context.get("room_player_position",{}),Vector2(640,500))),
  "return_world_position":vec_to_json(json_to_vec(context.get("return_world_position",{}),Vector2(400,1380)))
 }

static func make_envelope(slot_id:String,state_data:Dictionary,context:Dictionary,saved_at:int)->Dictionary:
 return {
  "schema_version":SCHEMA_VERSION,
  "content_version":CONTENT_VERSION,
  "save_id":slot_id+"-"+str(saved_at),
  "slot_id":slot_id,
  "saved_at":saved_at,
  "state":state_data,
  "context":normalize_context(context)
 }

static func validate_envelope(data:Dictionary)->bool:
 if int(data.get("schema_version",-1))!=SCHEMA_VERSION:return false
 if str(data.get("content_version",""))!=CONTENT_VERSION:return false
 if not data.get("state") is Dictionary:return false
 if not data.get("context") is Dictionary:return false
 if not data.get("saved_at") is int and not data.get("saved_at") is float:return false
 var ctx:Dictionary=data.context
 if str(ctx.get("current_room","")) not in VALID_ROOMS:return false
 for key in ["world_player_position","room_player_position","return_world_position"]:
  if not ctx.get(key) is Dictionary:return false
  var parsed:=json_to_vec(ctx[key],Vector2.INF)
  if not parsed.is_finite():return false
 return true

static func slot_path(slot:int)->String:
 return str(SLOT_PATHS.get(slot,""))

static func write_autosave(state_data:Dictionary,context:Dictionary,saved_at:int)->bool:
 if not ensure_root():return false
 return ProgressStore.write_save(AUTOSAVE,make_envelope("autosave",state_data,context,saved_at))

static func write_slot(slot:int,state_data:Dictionary,context:Dictionary,saved_at:int)->bool:
 var path:=slot_path(slot)
 if path.is_empty() or not ensure_root():return false
 return ProgressStore.write_save(path,make_envelope("slot_"+str(slot),state_data,context,saved_at))

static func read_envelope(path:String)->Dictionary:
 var primary:Dictionary=ProgressStore.read_save(path)
 if not primary.is_empty() and validate_envelope(primary):
  return primary
 var backup:Dictionary=ProgressStore.read_save(path+".bak")
 if not backup.is_empty() and validate_envelope(backup):
  return backup
 return {}

static func read_autosave()->Dictionary:
 return read_envelope(AUTOSAVE)

static func read_slot(slot:int)->Dictionary:
 var path:=slot_path(slot)
 return {} if path.is_empty() else read_envelope(path)

static func load_state(path:String,state_script:Script)->Dictionary:
 return load_envelope_state(read_envelope(path),state_script)

static func load_envelope_state(envelope:Dictionary,state_script:Script)->Dictionary:
 if envelope.is_empty() or not validate_envelope(envelope):
  return {"ok":false,"error":"invalid_save"}
 var temp_path:=ROOT+"/.validate_state.json"
 if not ensure_root() or not ProgressStore.write_save(temp_path,envelope.state):
  return {"ok":false,"error":"validate_write_failed"}
 var candidate=state_script.new()
 var ok:bool=candidate.load_from(temp_path)
 ProgressStore.remove_save_family(temp_path)
 if not ok:return {"ok":false,"error":"invalid_state"}
 return {"ok":true,"state":candidate,"context":envelope.context,"meta":envelope}

static func export_current(path:String,state_data:Dictionary,context:Dictionary,saved_at:int)->bool:
 if path.is_empty():return false
 var envelope:=make_envelope("export",state_data,context,saved_at)
 var temp:=path+".tmp"
 var file:=FileAccess.open(temp,FileAccess.WRITE)
 if file==null:return false
 file.store_string(JSON.stringify(envelope))
 file.flush()
 file.close()
 if FileAccess.file_exists(path):
  DirAccess.remove_absolute(path)
 return DirAccess.rename_absolute(temp,path)==OK

static func import_state(path:String,state_script:Script)->Dictionary:
 if path.is_empty() or not FileAccess.file_exists(path):
  return {"ok":false,"error":"missing_file"}
 var file:=FileAccess.open(path,FileAccess.READ)
 if file==null or file.get_length()>1048576:
  return {"ok":false,"error":"file_too_large"}
 var text:=file.get_as_text()
 file.close()
 var parser:=JSON.new()
 if parser.parse(text)!=OK or not parser.data is Dictionary:
  return {"ok":false,"error":"invalid_json"}
 var envelope:Dictionary=parser.data
 return load_envelope_state(envelope,state_script)

static func load_autosave_state(state_script:Script)->Dictionary:
 return load_state(AUTOSAVE,state_script)

static func load_slot_state(slot:int,state_script:Script)->Dictionary:
 var path:=slot_path(slot)
 return {"ok":false,"error":"invalid_slot"} if path.is_empty() else load_state(path,state_script)

static func migration_done()->bool:
 return FileAccess.file_exists(MIGRATION_MARKER)

static func mark_migration_done()->bool:
 if not ensure_root():return false
 var file:=FileAccess.open(MIGRATION_MARKER,FileAccess.WRITE)
 if file==null:return false
 file.store_string(str(Time.get_unix_time_from_system()))
 file.flush()
 file.close()
 return true

static func migrate_v3(path:String,state_script:Script)->Dictionary:
 if migration_done():return {"ok":false,"error":"already_migrated"}
 var legacy:=ProgressStore.read_save_with_backup(path)
 if legacy.is_empty():return {"ok":false,"error":"no_legacy"}
 if int(legacy.get("version",-1))!=1 or int(legacy.get("journey_version",-1))!=1:
  return {"ok":false,"error":"not_journey_v3"}
 var temp_path:=ROOT+"/.migrate_validate.json"
 if not ensure_root() or not ProgressStore.write_save(temp_path,legacy):
  return {"ok":false,"error":"validate_write_failed"}
 var candidate=state_script.new()
 var valid:bool=candidate.load_from(temp_path)
 ProgressStore.remove_save_family(temp_path)
 if not valid:return {"ok":false,"error":"invalid_legacy"}
 var ctx={
  "world_player_position":Vector2(400,1380),
  "current_room":"",
  "room_player_position":Vector2(640,500),
  "return_world_position":Vector2(400,1380)
 }
 if not write_autosave(candidate.to_dict(),ctx,int(Time.get_unix_time_from_system())):
  return {"ok":false,"error":"migration_write_failed"}
 var verify:=load_autosave_state(state_script)
 if not bool(verify.get("ok",false)):
  return {"ok":false,"error":"migration_verify_failed"}
 if not mark_migration_done():
  return {"ok":false,"error":"migration_marker_failed"}
 return {"ok":true,"state":verify.state,"context":verify.context,"meta":verify.meta}

static func remove_slot(slot:int)->bool:
 var path:=slot_path(slot)
 return false if path.is_empty() else ProgressStore.remove_save_family(path)

static func remove_autosave()->bool:
 return ProgressStore.remove_save_family(AUTOSAVE)

static func remove_all_v4()->bool:
 var ok:=remove_autosave()
 for slot in [1,2,3]:ok=remove_slot(slot) and ok
 return ok
