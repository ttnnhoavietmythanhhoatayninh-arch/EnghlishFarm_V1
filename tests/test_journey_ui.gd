extends "res://tests/test_support.gd"
func _initialize()->void:call_deferred("run")
func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate()
 g.persistence_enabled=false
 root.add_child(g)
 await process_frame
 if not expect_test(g.screen=="difficulty" and not g.state.onboarded, "test_journey_ui.gd: g.screen==\"difficulty\" and not g.state.onboarded"): return
 g.select_difficulty("normal")
 if not expect_test(g.screen=="guide", "test_journey_ui.gd: g.screen==\"guide\""): return
 g.finish_guide()
 if not expect_test(g.state.onboarded and not g.dialog.visible, "test_journey_ui.gd: g.state.onboarded and not g.dialog.visible"): return
 if not expect_test(g.minimap.size.x<=260 and g.minimap.size.y<=180, "test_journey_ui.gd: g.minimap.size.x<=260 and g.minimap.size.y<=180"): return
 g.open_learning()
 if not expect_test(g.screen=="learn", "test_journey_ui.gd: g.screen==\"learn\""): return
 if not expect_test(not g.state.can_test("vocabulary"), "test_journey_ui.gd: not g.state.can_test(\"vocabulary\")"): return
 g.show_vocabulary(0)
 g.show_vocabulary(1)
 g.show_vocabulary(2)
 g.mark_studied("vocabulary")
 if not expect_test(g.state.can_test("vocabulary"), "test_journey_ui.gd: g.state.can_test(\"vocabulary\")"): return
 g.start_quiz("vocabulary")
 for w in g.curriculum.words.normal:g.answer_quiz(str(w.word))
 if not expect_test(g.state.completed.has("vocabulary"), "test_journey_ui.gd: g.state.completed.has(\"vocabulary\")"): return
 g.mark_studied("reading")
 g.start_quiz("reading")
 for q in g.lessons.normal.questions:g.answer_quiz(str(q.answers[0]))
 if not expect_test(g.state.seeds==3 and g.state.completed.has("reading"), "test_journey_ui.gd: g.state.seeds==3 and g.state.completed.has(\"reading\")"): return
 g.state.demo_mode=true
 for i in range(3):
  g.farm_action("plant",i)
  g.state.plots[i].planted_at-=43201
  g.farm_action("harvest",i)
 if not expect_test(g.state.level==2, "test_journey_ui.gd: g.state.level==2"): return
 g.state.accept_order()
 if not expect_test(g.state.start_delivery(), "test_journey_ui.gd: g.state.start_delivery()"): return
 g.tick_delivery(13.0)
 if not expect_test(g.state.order_stage==2 and not g.state.delivery_active, "test_journey_ui.gd: g.state.order_stage==2 and not g.state.delivery_active"): return
 g.interact_npc("emma")
 if not expect_test(g.screen=="npc", "test_journey_ui.gd: g.screen==\"npc\""): return
 g.enter_room("emma")
 if not expect_test(g.interior.visible, "test_journey_ui.gd: g.interior.visible"): return
 g.leave_room()
 if not expect_test(not g.interior.visible, "test_journey_ui.gd: not g.interior.visible"): return
 g.show_writing()
 if not expect_test(g.screen=="writing_lesson", "test_journey_ui.gd: g.screen==\"writing_lesson\""): return
 g.mark_studied("writing")
 g.show_writing()
 g.writing.text="Dear Mia, thank you for your order. I can bring three carrots tomorrow. Best wishes, Momo."
 g.writing.text_changed.emit()
 if not expect_test(not g.state.letter_draft.is_empty(), "test_journey_ui.gd: not g.state.letter_draft.is_empty()"): return
 g.queue_free()
 await process_frame
 finish_test("JOURNEY_UI_TESTS_PASSED")
