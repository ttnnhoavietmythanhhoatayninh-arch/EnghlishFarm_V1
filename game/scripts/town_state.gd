extends "res://game/scripts/learning_state.gd"
var produce:=0
var wood:=0
var order_stage:=0
var tool_level:=1
var friendship:Dictionary={}
var demo_mode:=true
var letter_draft:=""
func accept_order()->bool:
 if order_stage not in [0,2]:return false
 order_stage=1
 return true
func deliver_order()->bool:
 if order_stage!=1 or produce<3:return false
 produce-=3
 cards+=8
 wood+=5
 friendship["mia"]=int(friendship.get("mia",0))+1
 order_stage=2
 return true
func upgrade_tools()->bool:
 if wood<5 or tool_level>=2:return false
 wood-=5
 tool_level=2
 return true
func harvest(index:int,time:int)->int:
 var reward:int=super.harvest(index,time)
 if reward>0:produce+=1
 return reward
func to_dict()->Dictionary:
 var d:Dictionary=super.to_dict()
 d.merge({"produce":produce,"wood":wood,"order_stage":order_stage,"tool_level":tool_level,"friendship":friendship,"demo_mode":demo_mode,"letter_draft":letter_draft})
 return d
func load_from(path:String)->bool:
 if not super.load_from(path):return false
 var d:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(path))
 produce=maxi(0,int(d.get("produce",0)))
 wood=maxi(0,int(d.get("wood",0)))
 order_stage=clampi(int(d.get("order_stage",0)),0,2)
 tool_level=clampi(int(d.get("tool_level",1)),1,2)
 friendship=d.get("friendship",{}) if d.get("friendship",{}) is Dictionary else {}
 demo_mode=bool(d.get("demo_mode",true))
 letter_draft=str(d.get("letter_draft","")).left(10000)
 return true

func crop_status(index:int,time:int)->String:
 if not demo_mode:return super.crop_status(index,time)
 if index<0 or index>=plots.size():return "invalid"
 var p:Dictionary=plots[index]
 if p.is_empty():return "empty"
 if time>int(p.watered_at)+129600:return "wilted"
 return "ready" if time>=int(p.planted_at)+43200 else "growing"
