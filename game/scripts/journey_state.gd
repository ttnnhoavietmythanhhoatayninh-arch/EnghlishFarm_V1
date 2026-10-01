extends "res://game/scripts/town_state.gd"
const LEVEL_TASKS={1:["vocabulary","reading","harvest"],2:["delivery","grammar","letter"],3:["house","fishing","bank"],4:["orchard","outfit","power"]}
var level:=1
var onboarded:=false
var difficulty_chosen:=false
var tutorial_index:=0
var studied:Dictionary={}
var completed:Dictionary={}
var bank_balance:=0
var fish:=0
var house_level:=1
var orchard_open:=false
var outfit_owned:=false
var delivery_active:=false
var delivery_seconds:=0.0
var fishing_day:=-1
var harvested_total:=0
func choose_difficulty(mode:String)->bool:
 if mode not in ["easy","normal","hard"]:return false
 difficulty=mode;difficulty_chosen=true
 return true
func study(topic:String)->void:studied[difficulty+":"+topic]=true
func can_test(topic:String)->bool:return studied.get(difficulty+":"+topic,false)
func level_points()->int:
 var points:=0
 for id in LEVEL_TASKS.get(level,[]):
  if completed.has(id):points+=1
 return points
func complete_task(id:String)->bool:
 if completed.has(id) or id not in LEVEL_TASKS.get(level,[]):return false
 completed[id]=true
 if level_points()==3:
  level=mini(level+1,5);powers+=1
 return true
func deposit(amount:int)->bool:
 if level<3 or amount<=0 or cards<amount:return false
 cards-=amount;bank_balance+=amount;complete_task("bank")
 return true
func withdraw(amount:int)->bool:
 if level<3 or amount<=0 or bank_balance<amount:return false
 bank_balance-=amount;cards+=amount
 return true
func catch_fish(success:bool)->bool:
 var today:=day(int(Time.get_unix_time_from_system()))
 if level<3 or not success or fishing_day==today:return false
 fish+=1;cards+=3;fishing_day=today;complete_task("fishing")
 return true
func improve_home()->bool:
 if level<3 or house_level>=2 or wood<5:return false
 wood-=5;house_level=2;complete_task("house")
 return true
func expand_orchard()->bool:
 if level<4 or orchard_open or cards<6:return false
 cards-=6;orchard_open=true;complete_task("orchard")
 return true
func buy_outfit()->bool:
 if level<4 or outfit_owned or cards<4:return false
 cards-=4;outfit_owned=true;complete_task("outfit")
 return true
func buy_power()->bool:
 if level<4 or cards<3:return false
 cards-=3;powers+=1;complete_task("power")
 return true
func start_delivery()->bool:
 if level<2 or order_stage!=1 or produce<3 or delivery_active:return false
 delivery_active=true;delivery_seconds=0.0
 return true
func finish_delivery()->bool:
 if not delivery_active:return false
 delivery_active=false
 if not super.deliver_order():return false
 complete_task("delivery")
 return true
func harvest(index:int,time:int)->int:
 var result:int=super.harvest(index,time)
 if result>0:
  harvested_total+=1
  if harvested_total>=3:complete_task("harvest")
 return result
func to_dict()->Dictionary:
 var d:Dictionary=super.to_dict()
 d.merge({"journey_version":1,"level":level,"onboarded":onboarded,"difficulty_chosen":difficulty_chosen,"tutorial_index":tutorial_index,"studied":studied,"completed":completed,"bank_balance":bank_balance,"fish":fish,"house_level":house_level,"orchard_open":orchard_open,"outfit_owned":outfit_owned,"delivery_active":delivery_active,"delivery_seconds":delivery_seconds,"fishing_day":fishing_day,"harvested_total":harvested_total})
 return d
func load_from(path:String)->bool:
 if not super.load_from(path):return false
 var d:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(path))
 if d.get("journey_version")!=1:return false
 level=clampi(int(d.get("level",1)),1,5)
 onboarded=bool(d.get("onboarded",false));difficulty_chosen=bool(d.get("difficulty_chosen",false));tutorial_index=clampi(int(d.get("tutorial_index",0)),0,8)
 studied=d.get("studied",{}) if d.get("studied",{}) is Dictionary else {}
 completed=d.get("completed",{}) if d.get("completed",{}) is Dictionary else {}
 bank_balance=maxi(0,int(d.get("bank_balance",0)));fish=maxi(0,int(d.get("fish",0)))
 house_level=clampi(int(d.get("house_level",1)),1,2)
 orchard_open=bool(d.get("orchard_open",false));outfit_owned=bool(d.get("outfit_owned",false))
 delivery_active=bool(d.get("delivery_active",false));delivery_seconds=clampf(float(d.get("delivery_seconds",0)),0,12)
 fishing_day=int(d.get("fishing_day",-1));harvested_total=maxi(0,int(d.get("harvested_total",0)))
 return true
