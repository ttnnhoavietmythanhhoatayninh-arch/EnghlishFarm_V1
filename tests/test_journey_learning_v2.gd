extends SceneTree

func _initialize()->void:
 call_deferred("run")

func words_of(items:Array)->Array[String]:
 var out:Array[String]=[]
 for item in items:out.append(str(item[0]))
 return out

func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate()
 g.persistence_enabled=false
 root.add_child(g)
 await process_frame
 g.state.choose_difficulty("easy")
 g.state.onboarded=true
 g.state.level=1

 # Same game level: consecutive Learn sessions must rotate to different 3-word sets.
 g.begin_vocabulary_session()
 var first:=words_of(g.active_vocab)
 g.begin_vocabulary_session()
 var second:=words_of(g.active_vocab)
 assert(first.size()==3 and second.size()==3)
 for w in first:assert(w not in second,"Consecutive vocabulary sessions must not repeat words before pool cycle")

 # Different game levels must use different vocabulary pools/topics.
 var level1_topic:=g.learning_topic()
 g.state.level=2
 g.begin_vocabulary_session()
 var level2:=words_of(g.active_vocab)
 assert(g.learning_topic()!=level1_topic)
 for w in first:assert(w not in level2,"Different levels should not reuse the same core pool")

 # The full learning bank must cover A1 through C2 across the three tracks.
 var cefr_seen:Dictionary={}
 var question_types:Dictionary={}
 for difficulty in ["easy","normal","hard"]:
  g.state.difficulty=difficulty
  for level in range(1,6):
   g.state.level=level
   var data:Dictionary=g.learning_level_data()
   assert(data.vocabulary.size()>=9,"Each level needs at least 9 vocabulary items")
   cefr_seen[str(data.cefr)]=true
   var reading:Dictionary=data.reading
   assert(reading.questions.size()==3,"Each reading lesson must contain 3 questions")
   for q in reading.questions:question_types[str(q.type)]=true
 assert(cefr_seen.keys().has("A1"))
 assert(cefr_seen.keys().has("A2"))
 assert(cefr_seen.keys().has("B1"))
 assert(cefr_seen.keys().has("B2"))
 assert(cefr_seen.keys().has("C1"))
 assert(cefr_seen.keys().has("C2"))
 for kind in ["true_false_not_given","yes_no_not_given","completion","matching","short_answer"]:
  assert(question_types.has(kind),"Reading bank must include "+kind)

 # B1+ tracks expose VSTEP-style Task 2 while A1/A2 keeps Task 1 manageable.
 g.state.difficulty="easy";g.state.level=1
 assert(g.writing_data().has("task1"))
 assert(not g.writing_data().has("task2"))
 g.state.difficulty="normal";g.state.level=1
 assert(g.writing_data().has("task2"))
 g.state.difficulty="hard";g.state.level=5
 assert(g.writing_data().has("task2"))

 print("JOURNEY_LEARNING_V2_PASSED")
 g.queue_free()
 await process_frame
 quit()
