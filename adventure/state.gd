extends Node

signal progress_changed
signal save_status_changed

const Catalog = preload("res://adventure/catalog.gd")
const SAVE_VERSION = 3
const WEB_SAVE_KEY = "rafinha2d.castle_progress"
const DEFAULT_SAVE_PATH = "user://castle_adventure_v1.json"

var save_path: String = DEFAULT_SAVE_PATH
var current_level: int = 0
var unlocked_level: int = 0
var completed_levels: Array[int] = []
var rescued_dogs: Array[String] = []
var finished: bool = false
var poop_collected: int = 0
var leader_name: String = "Rafinha"
var assist_friends: bool = true
var sound_on: bool = true
var has_save: bool = false
var saving_available: bool = true
var save_notice: String = ""

func _ready() -> void:
	# CI never reads or writes the family's save.
	if "--adventure-tests" in OS.get_cmdline_user_args():
		save_path = "user://castle_test_progress.json"
		return
	load_progress()
	if OS.has_feature("web") and not OS.is_userfs_persistent():
		saving_available = false
		save_notice = "Este navegador não guarda o progresso após fechar."

func new_adventure() -> void:
	current_level = 0
	unlocked_level = 0
	completed_levels.clear()
	rescued_dogs.clear()
	finished = false
	poop_collected = 0
	has_save = true
	save_progress()
	progress_changed.emit()

func rescue_dog(dog_id: String) -> bool:
	if not Catalog.DOGS.has(dog_id) or dog_id in rescued_dogs:
		return false
	# The first dog is always Fófins, even when content is added later.
	if dog_id != "fofins" and not "fofins" in rescued_dogs:
		return false
	rescued_dogs.append(dog_id)
	save_progress()
	progress_changed.emit()
	return true

func can_finish_level(index: int) -> bool:
	if index < 0 or index >= Catalog.LEVELS.size():
		return false
	for id in Catalog.required_dogs(index):
		if not id in rescued_dogs:
			return false
	return true

func complete_level(index: int) -> bool:
	if index != current_level or not can_finish_level(index):
		return false
	if not index in completed_levels:
		completed_levels.append(index)
	if index + 1 < Catalog.LEVELS.size():
		current_level = index + 1
		unlocked_level = maxi(unlocked_level, current_level)
	else:
		finished = true
	save_progress()
	progress_changed.emit()
	return true

func save_progress() -> bool:
	var data = {
		"version": SAVE_VERSION, "current_level": current_level, "unlocked_level": unlocked_level,
		"completed_levels": completed_levels, "rescued_dogs": rescued_dogs,
		"finished": finished, "poop_collected": poop_collected, "leader_name": leader_name, "assist_friends": assist_friends, "sound_on": sound_on,
	}
	# A synchronous Web snapshot survives an immediate browser reload while
	# Godot's IndexedDB filesystem is still synchronizing in the background.
	var web_saved: bool = false
	if OS.has_feature("web"):
		var expression: String = "(()=>{try{localStorage.setItem(" + JSON.stringify(WEB_SAVE_KEY) + "," + JSON.stringify(JSON.stringify(data)) + ");return true;}catch(e){return false;}})()"
		web_saved = bool(JavaScriptBridge.eval(expression, true))
	var file = FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
	if file == null:
		return _file_save_failed(web_saved)
	file.store_string(JSON.stringify(data))
	file.flush()
	var error: Error = file.get_error()
	file.close()
	if error != OK:
		return _file_save_failed(web_saved)
	var result: Error = DirAccess.rename_absolute(save_path + ".tmp", save_path)
	if result != OK:
		return _file_save_failed(web_saved)
	_mark_save_success(web_saved)
	return true

func _mark_save_success(web_saved: bool) -> void:
	has_save = true
	saving_available = web_saved or not OS.has_feature("web") or OS.is_userfs_persistent()
	save_notice = "" if saving_available else "Este navegador não guarda o progresso após fechar."
	save_status_changed.emit()

func _file_save_failed(web_saved: bool) -> bool:
	if web_saved:
		_mark_save_success(true)
		return true
	_save_failed()
	return false

func _save_failed() -> void:
	saving_available = false
	save_notice = "Pode jogar! O navegador não conseguiu guardar esta aventura."
	save_status_changed.emit()

func load_progress() -> bool:
	var raw: String = ""
	if OS.has_feature("web"):
		var stored = JavaScriptBridge.eval("(()=>{try{return localStorage.getItem(" + JSON.stringify(WEB_SAVE_KEY) + ");}catch(e){return null;}})()", true)
		if stored is String:
			raw = stored
	if raw.is_empty():
		if not FileAccess.file_exists(save_path):
			return false
		raw = FileAccess.get_file_as_string(save_path)
	var json = JSON.new()
	if json.parse(raw) != OK:
		save_notice = "O progresso antigo não pôde ser aberto. Comece uma nova aventura."
		return false
	var parsed = json.data
	if not parsed is Dictionary:
		return false
	var version = parsed.get("version", 0)
	if (not version is int and not version is float) or int(version) not in [1, 2, SAVE_VERSION]:
		save_notice = "O progresso antigo não pôde ser aberto. Comece uma nova aventura."
		return false
	# Reject malformed saves without leaving partial state behind.
	for key in ["current_level", "unlocked_level"]:
		if not parsed.get(key) is float and not parsed.get(key) is int:
			return false
	for key in ["completed_levels", "rescued_dogs"]:
		if not parsed.get(key) is Array:
			return false
	var dogs: Array[String] = []
	for old_id in parsed["rescued_dogs"]:
		var id = "tokio" if old_id == "amigo_provisorio" else old_id
		if id is String and Catalog.DOGS.has(id) and not id in dogs:
			dogs.append(id)
	if not dogs.is_empty() and dogs[0] != "fofins":
		return false
	var done: Array[int] = []
	for id in parsed["completed_levels"]:
		if (id is float or id is int) and int(id) >= 0 and int(id) < Catalog.LEVELS.size() and not int(id) in done:
			done.append(int(id))
	current_level = clampi(int(parsed["current_level"]), 0, Catalog.LEVELS.size() - 1)
	unlocked_level = clampi(int(parsed["unlocked_level"]), current_level, Catalog.LEVELS.size() - 1)
	# A festa antiga desbloqueia a expansão sem apagar os resgates.
	if parsed.get("version", 0) == 1 and bool(parsed.get("finished", false)) and done.size() == 3:
		current_level = 3
		unlocked_level = maxi(unlocked_level, 3)
	# Added rescue: a completed v2 adventure returns to Snoopy's castle.
	if int(version) < 3 and not "snoopy" in dogs and (current_level > 3 or 3 in done):
		current_level = 3
		done.assign(done.filter(func(index): return index < 3))
	completed_levels = done
	rescued_dogs = dogs
	finished = bool(parsed.get("finished", false)) and done.size() == Catalog.LEVELS.size()
	leader_name = parsed.get("leader_name", "Rafinha") if parsed.get("leader_name", "Rafinha") in ["Rafinha", "Bigo"] else "Rafinha"
	assist_friends = bool(parsed.get("assist_friends", true))
	sound_on = bool(parsed.get("sound_on", true))
	poop_collected = maxi(0, int(parsed.get("poop_collected", 0))) if parsed.get("poop_collected", 0) is float or parsed.get("poop_collected", 0) is int else 0
	has_save = true
	return true
