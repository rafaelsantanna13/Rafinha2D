extends Node

signal progress_changed
signal save_status_changed

const Catalog = preload("res://adventure/catalog.gd")
const SAVE_VERSION = 1
const DEFAULT_SAVE_PATH = "user://castle_adventure_v1.json"

var save_path: String = DEFAULT_SAVE_PATH
var current_level: int = 0
var unlocked_level: int = 0
var completed_levels: Array[int] = []
var rescued_dogs: Array[String] = []
var finished: bool = false
var leader_name: String = "Rafinha"
var assist_friends: bool = true
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
	var dog_id: String = Catalog.LEVELS[index]["dog"]
	return dog_id.is_empty() or dog_id in rescued_dogs

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
		"finished": finished, "leader_name": leader_name, "assist_friends": assist_friends,
	}
	var file = FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
	if file == null:
		_save_failed()
		return false
	file.store_string(JSON.stringify(data))
	file.flush()
	var error: Error = file.get_error()
	file.close()
	if error != OK:
		_save_failed()
		return false
	var result: Error = DirAccess.rename_absolute(save_path + ".tmp", save_path)
	if result != OK:
		_save_failed()
		return false
	has_save = true
	saving_available = not OS.has_feature("web") or OS.is_userfs_persistent()
	save_notice = "" if saving_available else "Este navegador não guarda o progresso após fechar."
	save_status_changed.emit()
	return true

func _save_failed() -> void:
	saving_available = false
	save_notice = "Pode jogar! O navegador não conseguiu guardar esta aventura."
	save_status_changed.emit()

func load_progress() -> bool:
	if not FileAccess.file_exists(save_path):
		return false
	var json = JSON.new()
	if json.parse(FileAccess.get_file_as_string(save_path)) != OK:
		save_notice = "O progresso antigo não pôde ser aberto. Comece uma nova aventura."
		return false
	var parsed = json.data
	if not parsed is Dictionary or parsed.get("version", 0) != SAVE_VERSION:
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
	for id in parsed["rescued_dogs"]:
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
	completed_levels = done
	rescued_dogs = dogs
	finished = bool(parsed.get("finished", false)) and done.size() == Catalog.LEVELS.size()
	leader_name = parsed.get("leader_name", "Rafinha") if parsed.get("leader_name", "Rafinha") in ["Rafinha", "Bigo"] else "Rafinha"
	assist_friends = bool(parsed.get("assist_friends", true))
	has_save = true
	return true
