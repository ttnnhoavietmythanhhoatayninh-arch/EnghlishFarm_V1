extends SceneTree

func _initialize()->void:
 call_deferred("run")

func run()->void:
 var g=load("res://game/scenes/Journey.tscn").instantiate()
 g.persistence_enabled=false
 root.add_child(g)
 await process_frame

 g.state.choose_difficulty("easy")
 g.state.onboarded=true
 g.state.level=2
 g.nav.unlocked_level=2
 g.state.cards=10
 g.state.wood=0
 g.state.produce=3
 g.state.order_stage=0
 g.state.delivery_active=false
 g.state.completed.clear()

 var mia:Dictionary=g.npc_by_id("mia")
 assert(not mia.is_empty())
 assert(mia.has("delivery"),"Mia/Market must define a dedicated delivery point")
 var delivery_world:Vector2=Vector2(mia.delivery)*2
 assert(g.nav.allowed(delivery_world),"Market delivery point must be in unlocked region")
 assert(g.nav.is_walkable(delivery_world,12.0),"Market delivery point must be on walkable ground")

 assert(g.state.accept_order(),"Mia order must be accepted")
 g.prepare_truck_route()
 assert(not g.truck_route.is_empty(),"Truck must have a route from farm to Market")
 assert(g.truck_route[g.truck_route.size()-1].distance_to(delivery_world)<90.0,"Truck route must end at Market delivery point")

 var before_cards:int=g.state.cards
 var before_wood:int=g.state.wood
 var before_friend:int=int(g.state.friendship.get("mia",0))
 g.begin_delivery()
 assert(g.state.delivery_active,"Delivery must start with 3 carrots")
 assert(g.state.produce==3,"Carrots are deducted only when Mia receives delivery")

 g.tick_delivery(6.0)
 assert(g.state.delivery_active,"Delivery must still be active halfway")
 assert(g.state.produce==3,"No carrots deducted before arrival")
 assert(g.state.cards==before_cards,"No reward before arrival")

 g.tick_delivery(6.1)
 assert(not g.state.delivery_active,"Delivery must complete after 12 seconds")
 assert(g.state.produce==0,"Exactly 3 carrots must be delivered")
 assert(g.state.cards==before_cards+8,"Delivery rewards 8 cards")
 assert(g.state.wood==before_wood+5,"Delivery rewards 5 wood")
 assert(int(g.state.friendship.get("mia",0))==before_friend+1,"Mia friendship increases by 1")
 assert(g.state.order_stage==2,"Order must be marked complete")
 assert(g.state.completed.has("delivery"),"Level 2 delivery task must complete")
 assert(g.player.visible,"Momo must be visible again after delivery")
 assert(g.nav.has_walkable_step(g.player.global_position),"Momo must be able to move after delivery")

  # A completed order must be repeatable without resetting or changing save format.
 assert(g.state.order_stage==2,"First delivery leaves order in completed state")
 g.state.produce=3
 var second_cards:int=g.state.cards
 var second_wood:int=g.state.wood
 var second_friend:int=int(g.state.friendship.get("mia",0))
 assert(g.state.accept_order(),"Completed Mia order must allow accepting a second order")
 assert(g.state.order_stage==1,"Second order becomes active")
 g.begin_delivery()
 assert(g.state.delivery_active,"Second delivery must start")
 g.tick_delivery(12.1)
 assert(not g.state.delivery_active,"Second delivery must complete")
 assert(g.state.produce==0,"Second delivery consumes exactly 3 carrots")
 assert(g.state.cards==second_cards+8,"Second delivery rewards another 8 cards")
 assert(g.state.wood==second_wood+5,"Second delivery rewards another 5 wood")
 assert(int(g.state.friendship.get("mia",0))==second_friend+1,"Second delivery increases Mia friendship again")
 assert(g.state.order_stage==2,"Second order returns to completed state")
 assert(g.nav.has_walkable_step(g.player.global_position),"Momo must still be movable after second delivery")

 print("JOURNEY_DELIVERY_PASSED")
 g.queue_free()
 await process_frame
 quit()
