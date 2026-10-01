extends SceneTree
func _initialize()->void:call_deferred("run")
func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate();g.persistence_enabled=false
 root.add_child(g);await process_frame
 assert(g.screen=="difficulty" and not g.state.onboarded)
 g.select_difficulty("normal");assert(g.screen=="guide")
 g.finish_guide();assert(g.state.onboarded and not g.dialog.visible)
 assert(g.minimap.size.x<=260 and g.minimap.size.y<=180)
 g.open_learning();assert(g.screen=="learn")
 assert(not g.state.can_test("vocabulary"))
 g.show_vocabulary(0)
 g.show_vocabulary(1)
 g.show_vocabulary(2)
 g.mark_studied("vocabulary");assert(g.state.can_test("vocabulary"))
 g.start_quiz("vocabulary")
 for w in g.curriculum.words.normal:g.answer_quiz(str(w.word))
 assert(g.state.completed.has("vocabulary"))
 g.mark_studied("reading");g.start_quiz("reading")
 for q in g.lessons.normal.questions:g.answer_quiz(str(q.answers[0]))
 assert(g.state.seeds==3 and g.state.completed.has("reading"))
 g.state.demo_mode=true
 for i in range(3):
  g.farm_action("plant",i);g.state.plots[i].planted_at-=43201;g.farm_action("harvest",i)
 assert(g.state.level==2)
 g.state.accept_order();assert(g.state.start_delivery())
 g.tick_delivery(13.0);assert(g.state.order_stage==2 and not g.state.delivery_active)
 g.interact_npc("emma");assert(g.screen=="npc")
 g.enter_room("emma");assert(g.interior.visible)
 g.leave_room();assert(not g.interior.visible)
 g.show_writing();assert(g.screen=="writing_lesson")
 g.mark_studied("writing");g.show_writing();g.writing.text="Dear Mia, thank you for your order. I can bring three carrots tomorrow. Best wishes, Momo."
 g.writing.text_changed.emit()
 assert(not g.state.letter_draft.is_empty())
 print("JOURNEY_UI_PASSED");g.queue_free();await process_frame;quit()
