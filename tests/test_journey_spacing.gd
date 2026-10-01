extends SceneTree

const SOURCE_FILES=[
 "res://game/scripts/journey_main.gd",
 "res://game/scripts/main.gd",
 "res://game/scripts/farm_state.gd"
]
const ALLOWED_TOKENS=["A1","A2","B1","B2","C1","F1","V3","V4","Camera2D"]

func _initialize()->void:
 var failures:Array[String]=[]
 for path in SOURCE_FILES:
  scan_text(path,FileAccess.get_file_as_string(path),failures)
 var dir:=DirAccess.open("res://data")
 if dir!=null:
  dir.list_dir_begin()
  var name:=dir.get_next()
  while name!="":
   if not dir.current_is_dir() and name.ends_with(".json"):
    var path:="res://data/"+name
    scan_text(path,FileAccess.get_file_as_string(path),failures)
   name=dir.get_next()
  dir.list_dir_end()
 for failure in failures:
  push_error(failure)
 if not failures.is_empty():
  push_error("Spacing violations: "+str(failures.size()))
  quit(1)
  return
 print("JOURNEY_SPACING_PASSED")
 quit(0)

func scan_text(path:String,source:String,failures:Array[String])->void:
 var literal_re:=RegEx.new()
 literal_re.compile("\"([^\\\"\\\\]|\\\\.)*\"")
 for match in literal_re.search_all(source):
  var literal:=match.get_string()
  if should_skip(literal):continue
  var clean:=literal.replace("\\n"," ").replace("\\t"," ")
  for token in ALLOWED_TOKENS:
   clean=clean.replace(token,"")
  var bad:=RegEx.new()
  bad.compile("[A-Za-zĐđ][0-9]|[0-9][A-Za-zĐđ]|,[0-9]|[A-Za-zĐđ][+-][0-9]")
  if bad.search(clean)!=null:
   var line:=source.substr(0,match.get_start()).count("\n")+1
   failures.append("%s:%d %s"%[path,line,literal])

func should_skip(literal:String)->bool:
 if "res://" in literal or "user://" in literal:return true
 if literal.ends_with(".json") or literal.ends_with(".svg") or literal.ends_with(".gd"):return true
 var hex_re:=RegEx.new()
 hex_re.compile("^\"?#?[0-9A-Fa-f]{6,8}\"?$")
 return hex_re.search(literal)!=null
