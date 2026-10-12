extends SceneTree

const Catalog = preload("res://adventure/catalog.gd")
var failures: Array[String] = []
var checks: int = 0
var state: Node

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, name: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", name)
	else:
		failures.append(name)
		print("FAIL: ", name)

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame

func key(code: Key, pressed: bool) -> void:
	var event = InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func scene(path: String) -> Node:
	change_scene_to_file(path)
	await frames(10)
	return current_scene

func _run() -> void:
	state = root.get_node("AdventureState")
	check(state.save_path != state.DEFAULT_SAVE_PATH, "Test save isolated from real progress")
	state.new_adventure()
	state.assist_friends = false
	for path in ["res://menu_inicial.tscn", "res://mundo_rafinha.tscn", "res://Mina.tscn", "res://pum_bigo.tscn", "res://adventure/celebration.tscn", Catalog.scene_for(0), Catalog.scene_for(1), Catalog.scene_for(2)]:
		var packed = load(path)
		check(packed is PackedScene and packed.can_instantiate(), "Scene loads: " + path)
		if packed is PackedScene:
			var instance = packed.instantiate()
			instance.free()
	for id in Catalog.DOGS:
		for visual_state in ["idle", "walk", "rescue", "follow"]:
			var texture = load("res://adventure/art/" + Catalog.DOGS[id]["art"] + "_" + visual_state + ".svg")
			check(texture is Texture2D and texture.get_width() > 0, "Dog SVG imports: " + id + " / " + visual_state)
	var original = await scene("res://mundo_rafinha.tscn")
	check(original.get_node("Rafinha") is CharacterBody2D and original.get_node("Bigo") is CharacterBody2D, "Original game still runs")
	var level = await scene(Catalog.scene_for(0))
	check(level.players.size() == 3, "All three original characters are playable")
	check(not state.rescue_dog("amigo_provisorio"), "Fófins must be rescued first")
	check(not level.request_exit(), "Gate stays closed before rescue")
	var mappings = [
		[0, KEY_RIGHT, KEY_LEFT, KEY_SPACE, "ui_right"],
		[1, KEY_D, KEY_A, KEY_V, "Bigodireita"],
		[2, KEY_3, KEY_1, KEY_L, "direitamarina"],
	]
	for row in mappings:
		var player = level.players[row[0]]
		player.global_position = Vector2(240, 625)
		player.velocity = Vector2.ZERO
		await frames(3)
		var start: float = player.position.x
		key(row[1], true)
		await frames(8)
		check(Input.is_action_pressed(row[4]) and player.position.x > start + 15, player.actor_name + " moves right with physical key")
		key(row[1], false)
		key(row[2], true)
		await frames(8)
		key(row[2], false)
		check(player.position.x < start + 10, player.actor_name + " moves left with physical key")
		await frames(3)
		key(row[3], true)
		await frames(12)
		key(row[3], false)
		check(player.position.y < 600.0, player.actor_name + " jumps with original key")
		await frames(55)
	key(KEY_E, true)
	await frames(3)
	key(KEY_E, false)
	check(level.players[1].pum.get_node("AnimationPlayer").current_animation == "aparecer_sumir", "Bigo E plays original pum scene")
	level.players[1].global_position = level.rescue_dog.position
	level.players[1].velocity = Vector2.ZERO
	await frames(50)
	check(state.rescued_dogs == ["fofins"], "Proximity rescues Fófins automatically")
	check(level.followers.dog_ids == ["fofins"], "Fófins joins followers")
	check(level.followers.leader.actor_name == "Rafinha", "Rafinha holds the guides by default")
	check(not state.rescue_dog("fofins"), "Repeated rescue is idempotent")
	var leader = level.followers.leader
	leader.set_physics_process(false)
	leader.global_position = Vector2(250, 625)
	level.followers.reset_trail()
	for i in range(85):
		leader.global_position.x += 5.0
		await frames(1)
	await frames(100)
	check(level.followers.dogs[0].position.x > 500.0, "Dog walks behind moving guide")
	check(level.followers.velocities[0].length() < 10.0, "Dog gradually stops when guide stops")
	check(absf(level.followers.dogs[0].position.x - leader.position.x) > 55.0, "Dog maintains formation spacing")
	var rose: bool = false
	for i in range(100):
		leader.global_position += Vector2(3.0, 0.0)
		leader.global_position.y = 625.0 - sin(minf(float(i) / 45.0, 1.0) * PI) * 78.0
		await frames(1)
		rose = rose or level.followers.dogs[0].position.y < 590.0
	check(rose, "Follower replays a jumping path")
	check(level.request_exit(), "Rescue unlocks transition")
	await frames(15)
	level = current_scene
	check(level.level_index == 1 and state.current_level == 1, "Transitions to second castle")
	check(level.followers.dog_ids == ["fofins"], "Fófins persists into second castle")
	level.players[0].global_position = level.rescue_dog.position
	level.players[0].velocity = Vector2.ZERO
	await frames(50)
	check(state.rescued_dogs == ["fofins", "amigo_provisorio"], "Second rescue accumulates dogs")
	check(level.followers.dogs.size() == 2, "Both dogs appear with guides")
	level._switch_guide()
	check(level.followers.leader.actor_name == "Bigo", "Guide can be configured to Bigo")
	level._switch_guide()
	check(level.followers.leader.actor_name == "Rafinha", "Guide can be returned to Rafinha")
	check(level.request_exit(), "Second castle advances")
	await frames(15)
	level = current_scene
	check(level.level_index == 2 and level.followers.dogs.size() == 2, "Final castle contains accumulated dogs")
	check(not level.request_exit(), "Final challenge gates celebration")
	for star in level.stars:
		level.players[0].global_position = star.position + Vector2(0, 30)
		level.players[0].velocity = Vector2.ZERO
		await frames(5)
	check(level.collected_stars == 3, "Physical proximity collects final paws")
	check(not level.collect_star(level.stars[0]), "A paw cannot be counted twice")
	check(level.request_exit(), "Completing final challenge opens celebration")
	await frames(15)
	check(state.finished and state.completed_levels == [0, 1, 2], "Three castles completed and final state saved")
	check(current_scene.name == "FestaDosAmigos", "Celebration scene loads")
	check(state.load_progress() and state.rescued_dogs.size() == 2 and state.finished, "Progress can be loaded from disk")
	var file = FileAccess.open(state.save_path, FileAccess.WRITE)
	file.store_string("{invalid")
	file.close()
	check(not state.load_progress() and state.rescued_dogs.size() == 2, "Corrupt save is handled without losing in-memory progress")
	var good_path: String = state.save_path
	state.save_path = "user://missing_test_folder/save.json"
	check(not state.save_progress() and not state.saving_available, "Unavailable storage is reported and play remains possible")
	state.save_path = good_path
	state.new_adventure()
	check(state.rescued_dogs.is_empty() and state.current_level == 0 and not state.finished, "Restart clears adventure progress")
	DirAccess.remove_absolute(state.save_path)
	print("ADVENTURE_TEST_SUMMARY: ", checks, " checks, ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
