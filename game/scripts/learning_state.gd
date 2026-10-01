extends RefCounted
# Offline prototype: timestamps are device-local, not cheat-proof.
var cards := 0
var powers := 0
var difficulty := "easy"
var learned: Dictionary = {}
var reviews: Dictionary = {}
var daily_words: Dictionary = {}
var daily_bonus: Dictionary = {}
var unlocked: Dictionary = {}
var seeds := 0
var plots: Array = [{}, {}, {}, {}, {}, {}]
var failures := 0
var blocked_until := 0
var login_day := -1
var login_streak := 0
var text_size := 20
func day(now: int) -> int:
 return int(floor(float(now) / 86400.0))
func learn_word(id: String, now: int) -> bool:
 if learned.has(id): return false
 learned[id] = now
 reviews[id] = now + 86400
 cards += 1
 var key := str(day(now))
 daily_words[key] = int(daily_words.get(key, 0)) + 1
 if int(daily_words[key]) >= 3 and not daily_bonus.has(key):
  cards += 3
  daily_bonus[key] = true
 blocked_until = 0
 failures = 0
 return true
func review_word(id: String, now: int) -> bool:
 if not learned.has(id) or now < int(reviews.get(id, 0)): return false
 cards += 1
 reviews[id] = now + 86400
 blocked_until = 0
 failures = 0
 return true
func claim_login(now: int) -> int:
 var today := day(now)
 if today <= login_day: return 0
 login_streak = mini(login_streak + 1, 7) if today == login_day + 1 else 1
 login_day = today
 powers += login_streak
 return login_streak
func unlock_seeds(id: String, correct: int, total: int) -> bool:
 if total != 3 or correct != total or unlocked.has(id): return false
 unlocked[id] = true
 seeds += 3
 return true
func crop_status(index: int, now: int) -> String:
 if index < 0 or index >= plots.size(): return "invalid"
 var p: Dictionary = plots[index]
 if p.is_empty(): return "empty"
 if now > int(p.watered_at) + 43200: return "wilted"
 if now >= int(p.planted_at) + 43200: return "ready"
 return "growing"
func plant(index: int, now: int) -> bool:
 if seeds < 1 or crop_status(index, now) not in ["empty", "wilted"]: return false
 plots[index] = {"planted_at":now,"watered_at":now}
 seeds -= 1
 return true
func water(index: int, now: int) -> bool:
 if crop_status(index, now) not in ["growing", "ready"]: return false
 plots[index]["watered_at"] = now
 return true
func harvest(index: int, now: int) -> int:
 if crop_status(index, now) != "ready": return 0
 plots[index] = {}
 cards += 2
 return 2
func challenge(correct: bool, now: int) -> bool:
 if now < blocked_until: return false
 if correct:
  failures = 0
  return true # Caller awards each content item only once.
 cards = maxi(0, cards - 1)
 failures += 1
 if failures >= 3:
  blocked_until = now + 1800
  failures = 0
 return false
func spend_power() -> bool:
 if powers <= 0: return false
 powers -= 1
 return true
func to_dict() -> Dictionary:
 return {"version":1,"cards":cards,"powers":powers,"difficulty":difficulty,"learned":learned,"reviews":reviews,"daily_words":daily_words,"daily_bonus":daily_bonus,"unlocked":unlocked,"seeds":seeds,"plots":plots,"failures":failures,"blocked_until":blocked_until,"login_day":login_day,"login_streak":login_streak,"text_size":text_size}
func save_to(path: String) -> bool:
 var file = FileAccess.open(path + ".tmp", FileAccess.WRITE)
 if file == null: return false
 file.store_string(JSON.stringify(to_dict()))
 file.close()
 return DirAccess.rename_absolute(path + ".tmp", path) == OK
func load_from(path: String) -> bool:
 if not FileAccess.file_exists(path): return false
 var parser := JSON.new()
 if parser.parse(FileAccess.get_file_as_string(path)) != OK: return false
 var data = parser.data
 if not data is Dictionary or data.get("version") != 1: return false
 for key in ["learned","reviews","daily_words","daily_bonus","unlocked"]:
  if not data.get(key) is Dictionary: return false
 if not data.get("plots") is Array or data.plots.size() != 6: return false
 for p in data.plots:
  if not p is Dictionary: return false
  if not p.is_empty() and (not p.has("watered_at") or not p.has("planted_at")): return false
 cards = maxi(0, int(data.get("cards",0)))
 powers = maxi(0, int(data.get("powers",0)))
 difficulty = str(data.get("difficulty","easy"))
 if difficulty not in ["easy","normal","hard"]: difficulty = "easy"
 learned = data.learned
 for id in learned: learned[id] = int(learned[id])
 reviews = data.reviews
 daily_words = data.daily_words
 daily_bonus = data.daily_bonus
 unlocked = data.unlocked
 plots = data.plots
 seeds = maxi(0, int(data.get("seeds",0)))
 failures = clampi(int(data.get("failures",0)),0,2)
 blocked_until = int(data.get("blocked_until",0))
 login_day = int(data.get("login_day",-1))
 login_streak = clampi(int(data.get("login_streak",0)),0,7)
 text_size = clampi(int(data.get("text_size",20)),16,28)
 return true
