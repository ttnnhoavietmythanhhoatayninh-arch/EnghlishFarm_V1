# Bước 1 — Mã đầy đủ các hàm và phần bổ sung

Base GitHub: `23bfa540cafc60155b0ee7c29e6952edcef66ff5`. Không thay main hoặc định dạng save V3.

## game/scripts/journey_main.gd

```gdscript
var save_path:=SAVE

func save_game()->void:
 if persistence_enabled and not state.save_to(save_path):notify("Không lưu được. Kiểm tra dung lượng và quyền ghi trên máy.")

func erase_save_file()->bool:
 if not FileAccess.file_exists(save_path):return true
 return DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))==OK

func setup_people()->void:
 npc_data=[
 {"id":"home","name":"Momo","role":"Nhà của bạn","relation":"Căn nhà và khu vườn đầu tiên của bạn.","place":"Nông trại (Farm)","at":Vector2(200,690),"door":Vector2(190,680),"exit":Vector2(190,735),"sprite":0,"level":1},
 {"id":"lily","name":"Lily","role":"Thủ thư","relation":"Người hướng dẫn học tập của Momo.","place":"Thư viện (Library)","at":Vector2(365,660),"door":Vector2(438,307),"exit":Vector2(438,362),"sprite":0,"level":1},
 {"id":"tom","name":"Tom","role":"Nông dân","relation":"Hàng xóm dạy Momo chăm vườn.","place":"Khu vườn (Garden)","at":Vector2(440,640),"door":Vector2(450,650),"exit":Vector2(450,705),"sprite":1,"level":1},
 {"id":"mia","name":"Mia","role":"Chủ tiệm","relation":"Khách hàng đầu tiên của Momo.","place":"Chợ (Market)","at":Vector2(920,580),"door":Vector2(940,590),"exit":Vector2(940,645),"sprite":2,"level":2},
 {"id":"emma","name":"Emma","role":"Bưu tá","relation":"Bạn giúp Momo trao đổi thư từ.","place":"Bưu điện (Post Office)","at":Vector2(1090,751),"door":Vector2(1020,756),"exit":Vector2(1020,811),"sprite":0,"level":2},
 {"id":"ben","name":"Ben","role":"Thợ mộc","relation":"Người giúp Momo sửa nhà.","place":"Xưởng mộc (Workshop)","at":Vector2(275,520),"door":Vector2(250,514),"exit":Vector2(250,569),"sprite":1,"level":3},
 {"id":"clara","name":"Clara","role":"Nhân viên ngân hàng","relation":"Người giữ thẻ tiết kiệm cho Momo.","place":"Ngân hàng (Bank)","at":Vector2(810,264),"door":Vector2(810,250),"exit":Vector2(810,305),"sprite":2,"level":3},
 {"id":"noah","name":"Noah","role":"Người câu cá","relation":"Bạn dạy Momo câu cá.","place":"Bến câu (Pier)","at":Vector2(1340,781),"door":Vector2(1310,778),"exit":Vector2(1310,833),"sprite":1,"level":3}]
 for n in npc_data:
  if n.id!="home":
   var node:=Node2D.new();var v=art.animated("npcs",{"idle":[n.sprite,n.sprite+3]},62.0);node.add_child(v);v.play("idle")
   var label:=Label.new();label.text=n.name+"\n"+n.role;label.position=Vector2(-65,-105);label.add_theme_font_size_override("font_size",16)
   label.add_theme_color_override("font_color",Color("342b24"));label.add_theme_stylebox_override("normal",Style.box("f9edcd"));node.add_child(label)
   add_child(node);npc_nodes[n.id]=node
  var sign:=Label.new();sign.text=n.place+"\nNhấn E để vào";sign.position=n.door*2+Vector2(-65,0);sign.z_index=3000
  sign.add_theme_font_size_override("font_size",15);sign.add_theme_color_override("font_color",Color("40362b"));sign.add_theme_stylebox_override("normal",Style.box("f1e1b6"))
  add_child(sign);door_nodes[n.id]=sign

func enter_room(id:String)->void:
 pending_npc=""
 pending_door=""
 if interior.visible and current_room==id:return
 var n:=npc_by_id(id)
 if n.is_empty() or state.level<n.level:return
 if id=="lily" and state.level<2:
  notify("Thư viện mở cấp 2. Lily đang đến nông trại dạy bạn.")
  return
 close_dialog()
 player.stop()
 world_player_position=player.global_position
 current_room=id
 interior.kind=id
 interior.upgraded=state.house_level>1
 interior.queue_redraw()
 interior.show()
 room_ui.show()
 room_has_target=false
 map_panel.hide()
 hint.hide()
 for b in command_buttons:
  b.visible=b.text in ["Farm","Letters","Settings","Tasks","Map","? Help"]
 for c in room_ui.get_children():
  if c!=room_hint:c.queue_free()
 room_hint.show()
 var data:Dictionary=interior.room_data(id)
 var leave:=make_button(room_ui,"Ra ngoài (Esc)",leave_room,50)
 leave.position=Vector2(535,540)
 leave.custom_minimum_size=Vector2(210,50)
 leave.size=Vector2(210,50)
 if player.get_parent()!=room_layer:
  player.reparent(room_layer)
 var camera:Camera2D=player.get_node("Camera2D")
 camera.enabled=false
 player.position=Vector2(640,500)
 player.show()
 tip_once("room","Nhấn Esc để ra ngoài.")
 update_room_hint()

func leave_room()->void:
 var room_id:=current_room
 var n:=npc_by_id(room_id)
 interior.hide()
 room_ui.hide()
 dialog.hide()
 screen=""
 current_room=""
 pending_npc=""
 pending_door=""
 fishing_running=false
 room_has_target=false
 if player.get_parent()!=self:
  player.reparent(self)
 var camera:Camera2D=player.get_node("Camera2D")
 camera.enabled=true
 player.stop()
 if not n.is_empty():
  var requested_exit:Vector2=n.door*2+Vector2(0,110)
  var exit_pt:Vector2=safe_walkable_near(requested_exit)
  if not nav.allowed(exit_pt) or not nav.is_walkable(exit_pt,12.0) or not has_walkable_step(exit_pt):
   exit_pt=safe_walkable_near(n.at*2)
  if not nav.allowed(exit_pt) or not nav.is_walkable(exit_pt,12.0) or not has_walkable_step(exit_pt):
   exit_pt=safe_walkable_near(Vector2(200,690)*2)
  player.global_position=exit_pt
 world_player_position=player.global_position
 player.locked=not state.onboarded or state.delivery_active
 hint.show()
 for b in command_buttons:b.show()
 get_viewport().gui_release_focus()

func safe_walkable_near(pt:Vector2)->Vector2:
 return nav.safe_walkable_near(pt)

func has_walkable_step(from:Vector2,toward:Vector2=Vector2.INF)->bool:
 return nav.has_walkable_step(from,toward)
```

## game/scripts/journey_navigation.gd

```gdscript
extends "res://game/scripts/town_navigation.gd"
var unlocked_level:=5
func allowed(point:Vector2)->bool:
 var p:=point/2.0
 if unlocked_level==1:return Rect2(120,600,440,220).has_point(p)
 if unlocked_level==2:return p.y>=280 and p.x<1200
 if unlocked_level==3:return not Rect2(1000,0,536,330).has_point(p)
 return true
func can_travel(from:Vector2,to:Vector2,clearance:float=8.0)->bool:
 return allowed(from) and allowed(to) and super.can_travel(from,to,clearance)


func safe_walkable_near(point:Vector2,max_distance:float=220.0)->Vector2:
 if not point.is_finite():
  push_warning("Cannot resolve a non-finite exit position.")
  return point
 if allowed(point) and is_walkable(point,12.0) and has_walkable_step(point):return point
 # Fine search requested by the room contract; each circle tests 32 directions.
 for radius in [5.0,15.0,30.0,50.0]:
  if radius>max_distance:continue
  for i in range(32):
   var p:Vector2=point+Vector2.from_angle(TAU*i/32.0)*radius
   if allowed(p) and is_walkable(p,12.0) and has_walkable_step(p):return p
 # Legacy exits can lie farther away. Search safe grid centers before giving up.
 var closest:=point
 var best_distance:=max_distance+0.01
 for cell in walkable_cells:
  var p:Vector2=grid.get_point_position(cell)
  var distance:=p.distance_to(point)
  if distance<best_distance and allowed(p) and is_walkable(p,12.0) and has_walkable_step(p):
   closest=p;best_distance=distance
 if best_distance<=max_distance:return closest
 push_warning("No safe exit found near "+str(point)+"; caller must keep or choose a known safe position.")
 return point

func has_walkable_step(from:Vector2,toward:Vector2=Vector2.INF)->bool:
 if not from.is_finite() or not allowed(from) or not is_walkable(from,12.0):return false
 if toward.is_finite():
  if from.distance_to(toward)<0.01:return false
  return can_travel(from,from+from.direction_to(toward)*24.0,12.0)
 for offset in [Vector2(24,0),Vector2(-24,0),Vector2(0,24),Vector2(0,-24)]:
  if can_travel(from,from+offset,12.0):return true
 return false

```

## game/scripts/town_navigation.gd

```gdscript
extends "res://game/scripts/farm_navigation.gd"
# Rectangles use source-image pixels (1536 x 1024), scaled exactly once below.
const OBSTACLES:Array[Rect2]=[
 Rect2(928,602,152,118), # Post office; leave east corridor to Noah open.
 Rect2(104,582,126,80), # Momo's house, stop at the front path.
 Rect2(935,337,158,186), # Market building and stalls.
 Rect2(1114,331,174,183), # Eastern shop walls.
 Rect2(318,106,215,164), # Library walls.
 Rect2(543,142,129,121), # Northern building.
 Rect2(761,78,206,141), # Bank building; preserve entrance apron.
 Rect2(300,739,48,12), # Farm lower fence segments; keep gate open.
 Rect2(235,751,60,12),
 Rect2(370,723,44,12),
 Rect2(443,676,12,32),
 Rect2(1440,380,80,360), # Open water beyond the bridge.
 Rect2(1410,870,100,100) # Water south of the pier.
]
func configure_regions() -> void:
 # Walkable surfaces traced in source-image pixels; base class scales by 2.
 _polygon([[515,375],[650,355],[825,350],[875,393],[911,455],[955,570],[914,625],[826,634],[650,634],[510,585]])
 _rectangle(Rect2(414,281,38,94))
 _rectangle(Rect2(414,332,239,43))
 _rectangle(Rect2(613,287,47,103))
 _rectangle(Rect2(635,287,391,43))
 _rectangle(Rect2(781,237,55,122))
 _rectangle(Rect2(760,222,260,58))
 _polygon([[988,288],[1040,249],[1080,230],[1260,266],[1255,312],[1080,275],[1020,327]])
 _polygon([[505,354],[546,364],[505,467],[514,555],[469,572],[449,504],[471,432]])
 _rectangle(Rect2(245,497,257,52))
 _rectangle(Rect2(329,466,55,65))
 _rectangle(Rect2(111,491,180,38))
 _polygon([[472,547],[523,553],[486,646],[457,681],[430,689],[433,636]])
 _polygon([[190,662],[306,633],[455,625],[459,655],[310,676],[201,699]])
 _rectangle(Rect2(173,663,47,55))
 _polygon([[175,721],[437,681],[458,724],[221,775],[171,766]])
 _polygon([[688,622],[741,622],[753,713],[792,810],[835,914],[791,935],[742,832],[709,752]])
 _polygon([[371,915],[421,900],[720,925],[795,925],[825,969],[756,1000],[713,972],[443,955],[370,950]])
 _polygon([[861,607],[907,595],[963,630],[925,671],[867,683],[841,659]])
 _polygon([[854,665],[889,656],[922,720],[1000,741],[1105,723],[1136,751],[1069,782],[971,786],[900,751]])
 _polygon([[920,583],[1142,537],[1239,514],[1289,518],[1283,556],[1174,574],[980,629]])
 _polygon([[1231,517],[1291,523],[1356,560],[1410,563],[1420,600],[1340,594],[1280,566],[1212,565]])
 _polygon([[1110,726],[1150,689],[1168,619],[1211,609],[1209,696],[1252,744],[1353,754],[1387,781],[1380,817],[1250,793],[1195,751],[1134,782]])
 for rect in OBSTACLES:
  blocked.append(Rect2(rect.position*SCALE,rect.size*SCALE))
 for rect in [Rect2(641,429,133,100),Rect2(631,367,154,54),Rect2(578,579,75,32),Rect2(758,578,92,30)]:
  blocked.append(Rect2(rect.position*SCALE,rect.size*SCALE).grow(8))

```

## tests/test_support.gd

```gdscript
extends SceneTree

# Unlike assert(), this records failure across helper/coroutine boundaries.
var test_failed := false

func expect_test(condition: bool, reason: String = "Expectation failed") -> bool:
	if not condition:
		test_failed = true
		printerr("FAIL: " + reason)
		for frame in get_stack():
			printerr("  %s:%s in %s" % [frame.source, frame.line, frame.function])
		quit(1)
	return condition

func finish_test(marker: String = "TEST_SUITE_PASSED") -> void:
	if test_failed:
		quit(1)
		return
	print(marker)
	quit(0)

```

## tools/run_tests.py

```python
#!/usr/bin/env python3
"""Run Godot suites, rejecting runtime errors even when Godot exits zero."""
import argparse
import os
from pathlib import Path
import re
import selectors
import time
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
ERROR = re.compile(r'SCRIPT ERROR:|(?:^|\n)\s*ERROR:|(?:^|\n)\s*FAIL:')
PASSED = re.compile(r'^[A-Z][A-Z0-9_]*PASSED\s*$', re.MULTILINE)


def run_engine(command, env, timeout):
    """Stream bounded chunks and stop at the first error, including partial lines."""
    output = bytearray()
    tail = ""
    passed = False
    reason = ""
    cap = 65536
    truncated = False
    try:
        process = subprocess.Popen(command, cwd=ROOT, env=env, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT, bufsize=0)
    except OSError as error:
        return str(error), "could not start Godot"
    selector = selectors.DefaultSelector()
    selector.register(process.stdout, selectors.EVENT_READ)
    deadline = time.monotonic() + timeout
    try:
        while selector.get_map():
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                reason = f"timeout after {timeout:g}s"
                break
            for key, _ in selector.select(min(remaining, 0.1)):
                chunk = os.read(key.fd, 4096)
                if not chunk:
                    selector.unregister(key.fileobj)
                    continue
                room = cap - len(output)
                output.extend(chunk[:room])
                truncated = truncated or len(chunk) > room
                tail += chunk.decode(errors="replace")
                match = ERROR.search(tail)
                if match:
                    detail = tail[match.start():].strip().splitlines()[0][:250]
                    reason = "runtime error: " + detail
                    break
                # Accept only complete lines; partial markers may gain suffixes.
                complete, separator, unfinished = tail.rpartition("\n")
                if separator:
                    passed = passed or bool(PASSED.search(complete))
                    tail = unfinished
                tail = tail[-4096:]
            if reason:
                break
        if not reason:
            passed = passed or bool(PASSED.fullmatch(tail))
            try:
                code = process.wait(timeout=max(0.01, deadline - time.monotonic()))
                reason = f"exit {code}" if code else "" if passed else "missing PASSED marker"
            except subprocess.TimeoutExpired:
                reason = f"timeout after {timeout:g}s"
    finally:
        selector.close()
        if process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
        process.stdout.close()
    text = output.decode(errors="replace")
    if truncated:
        text += "\n[Log capped at 64 KiB]\n"
    return text, reason


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', default=os.environ.get('GODOT', 'godot'))
    parser.add_argument('--timeout', type=float, default=60)
    parser.add_argument('--log-dir', type=Path, default=ROOT / 'build/test-logs')
    parser.add_argument('tests', nargs='*', help='Suite paths relative to project root')
    args = parser.parse_args()
    suites = [ROOT / name for name in args.tests] if args.tests else sorted((ROOT / 'tests').glob('test_*.gd'))
    suites = [p for p in suites if p.name != 'test_support.gd']
    if not suites:
        print('FAIL: No test suites found.', file=sys.stderr)
        return 1
    args.log_dir.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ, GODOT_SILENCE_ROOT_WARNING='1')
    for suite in suites:
        print(f'RUN {suite.name}', flush=True)
        command = [args.godot, '--headless', '--path', str(ROOT), '--script', str(suite)]
        output, reason = run_engine(command, env, args.timeout)
        log_path = args.log_dir / (suite.stem + '.log')
        log_path.write_text(output, encoding='utf-8')
        if reason:
            lines = output.splitlines()
            print("\n".join(lines[:60]))
            if len(lines) > 60:
                print("[Console output limited to the first 60 lines]")
            print(f'FAIL: {suite.name}: {reason}\nLog: {log_path}', file=sys.stderr)
            return 1
        print(f'PASS {suite.name}', flush=True)
    print(f'ALL {len(suites)} SUITES PASSED')
    return 0


if __name__ == '__main__':
    sys.exit(main())

```

