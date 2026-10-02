extends "res://tests/test_support.gd"

func _initialize()->void:
 var path:="res://data/learning_cefr_v2.json"
 if not expect_test(FileAccess.file_exists(path),"CEFR learning catalog must exist"):return
 var data=JSON.parse_string(FileAccess.get_file_as_string(path))
 if not expect_test(data is Dictionary and data.has("profiles"),"CEFR catalog must contain profiles"):return
 var seen_cefr:Dictionary={}
 var required_formats={"true_false_not_given":false,"yes_no_not_given":false,"completion":false,"matching":false,"short_answer":false}
 for mode in ["easy","normal","hard"]:
  if not expect_test(data.profiles.has(mode),"Missing profile "+mode):return
  var packs:Array=data.profiles[mode]
  if not expect_test(packs.size()==5,mode+" must have 5 game-level packs"):return
  var words_seen:Dictionary={}
  for level_index in range(5):
   var pack:Dictionary=packs[level_index]
   var cefr:=str(pack.get("cefr",""))
   seen_cefr[cefr]=true
   if not expect_test(cefr in ["A1","A2","B1","B2","C1","C2"],"Invalid CEFR "+cefr):return
   var words:Array=pack.get("words",[])
   if not expect_test(words.size()>=9,mode+" L"+str(level_index+1)+" needs >=9 words"):return
   var local:Dictionary={}
   for w in words:
    var id:=str(w.get("word","")).to_lower()
    if not expect_test(not id.is_empty(),"Vocabulary word cannot be empty"):return
    if not expect_test(not local.has(id),"Duplicate word inside pack: "+id):return
    if not expect_test(not words_seen.has(id),"Vocabulary must not repeat across game levels in "+mode+": "+id):return
    local[id]=true;words_seen[id]=true
   var reading:Dictionary=pack.get("reading",{})
   var questions:Array=reading.get("questions",[])
   if not expect_test(questions.size()==3,"Each reading activity must have 3 questions"):return
   for q in questions:
    var fmt:=str(q.get("format",""))
    if required_formats.has(fmt):required_formats[fmt]=true
    if not expect_test(q.has("answers") and q.answers is Array and not q.answers.is_empty(),"Reading question needs accepted answers"):return
   var writing:Dictionary=pack.get("writing",{})
   if not expect_test(str(writing.get("mode","")) in ["message","letter","task2"],"Invalid writing mode"):return
 for cefr in ["A1","A2","B1","B2","C1","C2"]:
  if not expect_test(seen_cefr.has(cefr),"Catalog must cover "+cefr):return
 for fmt in required_formats:
  if not expect_test(required_formats[fmt],"Reading catalog must include "+fmt):return
 var has_task2:=false
 var has_letter:=false
 for mode in data.profiles:
  for pack in data.profiles[mode]:
   has_task2=has_task2 or str(pack.writing.mode)=="task2"
   has_letter=has_letter or str(pack.writing.mode)=="letter"
 if not expect_test(has_letter and has_task2,"Writing must include VSTEP-oriented letter and Task 2 practice"):return
 finish_test("LEARNING_CEFR_CATALOG_PASSED")
