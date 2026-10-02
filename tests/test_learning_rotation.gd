extends "res://tests/test_support.gd"

func _initialize()->void:call_deferred("run")

func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate()
 g.persistence_enabled=false
 root.add_child(g)
 await process_frame
 g.state.choose_difficulty("easy")
 g.state.onboarded=true
 g.state.level=1
 var p1:Dictionary=g.current_learning_pack()
 if not expect_test(str(p1.cefr)=="A1","Easy level 1 should start at A1"):return
 var first:Array=g.current_vocab_words()
 if not expect_test(first.size()==3,"A vocabulary session contains 3 words"):return
 var first_ids:Array=[]
 for w in first:first_ids.append(str(w.word))
 g.advance_vocab_session()
 var second:Array=g.current_vocab_words()
 var second_ids:Array=[]
 for w in second:second_ids.append(str(w.word))
 if not expect_test(first_ids!=second_ids,"Next Learn session must rotate to different words"):return
 for id in first_ids:
  if not expect_test(id not in second_ids,"Vocabulary sessions must not overlap before pool exhaustion"):return
 g.state.level=2
 var level2:Array=g.current_learning_pack().words
 var level2_ids:Array=[]
 for w in level2:level2_ids.append(str(w.word))
 for id in first_ids:
  if not expect_test(id not in level2_ids,"Vocabulary must differ across game levels"):return
 g.state.choose_difficulty("normal");g.state.level=4
 if not expect_test(str(g.current_learning_pack().cefr)=="B2","Normal level 4 should use B2"):return
 g.state.choose_difficulty("hard");g.state.level=5
 if not expect_test(str(g.current_learning_pack().cefr)=="C2","Hard level 5 should use C2"):return
 var reading:Dictionary=g.current_learning_pack().reading
 if not expect_test(reading.questions.size()==3,"Current reading pack has 3 questions"):return
 var writing:Dictionary=g.current_learning_pack().writing
 if not expect_test(str(writing.mode)=="task2","Hard level 5 should expose Task 2 writing"):return
 g.queue_free()
 await process_frame
 finish_test("LEARNING_ROTATION_PASSED")
