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
	for path in ["res://menu_inicial.tscn", "res://mundo_rafinha.tscn", "res://Mina.tscn", "res://pum_bigo.tscn", "res://adventure/celebration.tscn", Catalog.scene_for(0), Catalog.scene_for(1), Catalog.scene_for(2), Catalog.scene_for(3), Catalog.scene_for(4), "res://adventure/actors/sloth.tscn"]:
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
	check(level.players.size() == 5, "All originals, sloth and Guilherme Jedi are playable")
	check(not state.rescue_dog("tokio"), "Fófins must be rescued first")
	check(not level.request_exit(), "Gate stays closed before rescue")
	var mappings = [
		[0, KEY_RIGHT, KEY_LEFT, KEY_SPACE, "ui_right"],
		[1, KEY_D, KEY_A, KEY_V, "Bigodireita"],
		[2, KEY_3, KEY_1, KEY_L, "direitamarina"],
		[3, KEY_K, KEY_J, KEY_U, "sloth_right"],
		[4, KEY_X, KEY_Z, KEY_B, "guilherme_right"],
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
		check(player.position.y < 600.0, player.actor_name + " jumps with assigned key")
		await frames(55)
	var used_keys: Dictionary = {}
	var conflict: bool = false
	for action in ["ui_left", "ui_right", "ui_accept", "Bigoesquerda", "Bigodireita", "Bigopula", "Tecla_bigopum", "esquerdamarina", "direitamarina", "pulamarina", "sloth_left", "sloth_right", "sloth_jump", "sloth_collect", "rafinha_judo", "guilherme_left", "guilherme_right", "guilherme_jump", "guilherme_force"]:
		for event in InputMap.action_get_events(action):
			if event is InputEventKey:
				var code: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
				if used_keys.has(code) and used_keys[code] != action:
					conflict = true
				used_keys[code] = action
	check(not conflict, "No keyboard conflicts among five actors and special abilities")
	level.sloth.position = Vector2(200, 625)
	level.sloth.velocity = Vector2.ZERO
	level.sloth.manual_time = 0.0
	level.players[1].position = Vector2(360, 625)
	level._take_control(level.players[1])
	await frames(10)
	check(absf(level.sloth.position.x - 200.0) < 1.0 and not level.sloth.catching_up, "Sloth remains still while group is close")
	state.assist_friends = false
	var remained_visible: bool = true
	key(KEY_D, true)
	for i in range(220):
		key(KEY_V, level.players[1].is_on_floor() and level.players[1].is_on_wall())
		await frames(1)
		remained_visible = remained_visible and level.sloth_is_visible()
	key(KEY_D, false)
	key(KEY_V, false)
	check(level.sloth.position.x > 350.0, "Forgotten sloth automatically follows, even with T assist disabled")
	check(remained_visible, "Sloth stays visible while the group crosses platforms")
	var before_c: Vector2 = level.sloth.position
	level._regroup()
	check(level.sloth.position.distance_to(before_c) < 1.0, "C does not teleport the sloth; edge-follow handles recovery")
	level._take_control(level.sloth)
	key(KEY_J, true)
	await frames(6)
	key(KEY_J, false)
	check(not level.sloth.catching_up and not level.sloth.automatic_follow, "Manual J immediately overrides automatic catch-up")
	key(KEY_E, true)
	await frames(3)
	key(KEY_E, false)
	check(level.players[1].pum.get_node("AnimationPlayer").current_animation == "aparecer_sumir", "Bigo E plays original pum scene")
	var villain = level.combat.villains[0]
	level.players[0].global_position = Vector2(250, 625)
	key(KEY_F, true)
	await frames(3)
	key(KEY_F, false)
	check(not villain.defeated, "Judô does not affect distant villains")
	await frames(60)
	level.players[0].global_position = villain.position - Vector2(90, 0)
	level.players[0].velocity = Vector2.ZERO
	await frames(3)
	key(KEY_RIGHT, true)
	await frames(35)
	key(KEY_RIGHT, false)
	check(level.players[0].position.x < villain.position.x - 20.0, "Cabeçudinho physically blocks walking")
	var blocked_x: float = level.players[0].position.x
	key(KEY_F, true)
	await frames(3)
	key(KEY_F, false)
	check(villain.defeated and villain.reaction == "judo" and level.combat.judo_hits == 1 and level.players[0].ability_time > 0, "Rafinha F performs mysterious judô and spins the villain")
	check(villain.collision_layer == 0, "Judô opens the physical passage without damaging players")
	key(KEY_RIGHT, true)
	await frames(12)
	key(KEY_RIGHT, false)
	check(level.players[0].position.x > blocked_x + 20.0, "Rafinha walks forward after judô")
	var target = load("res://adventure/combat/bighead.gd").new()
	target.position = Vector2(2150, 625)
	level.add_child(target)
	level.combat.villains.append(target)
	level.guilherme.position = Vector2(1700, 625)
	level.guilherme.velocity = Vector2.ZERO
	await frames(5)
	key(KEY_Q, true)
	await frames(3)
	key(KEY_Q, false)
	check(not target.defeated, "Force has a finite range")
	await frames(70)
	level.guilherme.position = Vector2(1990, 625)
	level.guilherme.velocity = Vector2.ZERO
	await frames(3)
	var enemy_start: float = target.position.x
	key(KEY_Q, true)
	await frames(30)
	key(KEY_Q, false)
	check(target.defeated and target.reaction == "force" and level.combat.force_hits == 1, "Guilherme Q uses the Force on a nearby villain")
	check(target.position.x > enemy_start + 65.0, "Force visibly pushes the villain away")
	level.players[1].global_position = level.data["rescues"]["fofins"]
	level.players[1].velocity = Vector2.ZERO
	await frames(50)
	check(state.rescued_dogs == ["fofins"], "Proximity rescues Fófins automatically")
	check(level.followers.dog_ids == ["fofins"], "Fófins joins followers")
	check(level.followers.leader.actor_name == "Rafinha", "Rafinha holds the guides by default")
	check(not state.rescue_dog("fofins"), "Repeated rescue is idempotent")
	level.followers.set_physics_process(false)
	var dog = level.followers.dogs[0]
	dog.global_position = Vector2(320, 625)
	level.poop.first_delay = 0.1
	level.poop.interval_seconds = 5.0
	level.poop.max_objects = 3
	level.poop.due_times.clear()
	await frames(30)
	check(level.poop.objects.size() > 0 and dog.poop_time > 0.0, "Rescued dog produces visible poop on a timer with an animation")
	check(level.poop.objects[0].global_position.y > 624.0 and level.poop.objects[0].global_position.y < 626.0, "Poop is placed on a real floor")
	check(level.poop.safe_ground(Vector2(1350, 450)) == null, "Airborne poop is rejected")
	check(level.poop.safe_ground(Vector2(450, 600)) == null, "Poop inside a wall is rejected")
	check(level.poop.safe_ground(Vector2(1350, 1000)) == null, "Poop below the world is rejected")
	for point in [Vector2(1350, 625), Vector2(1430, 625), Vector2(2100, 625)]:
		dog.global_position = point
		level.poop.try_generate(dog)
	check(level.poop.objects.size() == 3, "Simultaneous poop objects are capped")
	await frames(330)
	check(level.poop.objects.size() == 3, "Timer never bypasses object limit")
	var item = level.poop.objects[0]
	level.sloth.global_position = item.global_position + Vector2(200, 0)
	check(not level.poop.collect_near(level.sloth), "Sloth cannot collect from far away")
	level.sloth.global_position = item.global_position + Vector2(0, -80)
	check(not level.poop.collect_near(level.sloth), "Sloth cannot collect through another floor")
	level.players[1].global_position = item.global_position
	check(not level.poop.collect_near(level.players[1]), "Only the sloth collects poop")
	level.sloth.global_position = item.global_position + Vector2(30, 0)
	level.sloth.velocity = Vector2.ZERO
	await frames(3)
	key(KEY_I, true)
	await frames(3)
	key(KEY_I, false)
	check(item.collected and state.poop_collected == 1 and level.sloth.collect_time > 0.0, "Nearby I key collects poop and animates the sloth")
	check(level.poop.objects.size() == 2, "Collected object leaves the collectible list")
	await frames(20)
	check(not is_instance_valid(item), "Collected poop disappears after its short effect")
	level.poop.stop_and_clear()
	check(level.poop.objects.is_empty() and not level.poop.try_generate(dog), "Transition disables generation and clears poop")
	level.followers.set_physics_process(true)
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
	level.players[0].global_position = level.data["rescues"]["tokio"]
	level.players[0].velocity = Vector2.ZERO
	await frames(50)
	check(state.rescued_dogs == ["fofins", "tokio"], "Second rescue accumulates dogs")
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
	check(level.request_exit(), "Original paw challenge opens the two added castles")
	await frames(15)
	level = current_scene
	check(level.level_index == 3 and level.rescue_dogs.size() == 5, "Snoopy is the primary rescue alongside four friends in castle four")
	for index in [3, 4]:
		level = current_scene
		check(not level.request_exit(), "New castle requires all its rescues: " + str(index))
		check(level.followers.dogs.size() == (2 if index == 3 else 7), "All earlier dogs continue into castle " + str(index + 1))
		if index == 3:
			var snoopy: Area2D
			for waiting in level.rescue_dogs:
				if waiting.dog_id == "snoopy":
					snoopy = waiting
			check(snoopy.visual.is_sleeping and snoopy.visual.state == "sleep", "Snoopy sleeps on top of the red doghouse before rescue")
		if index == 4:
			check(level.richard.state == 0 and not level.richard.rabbit.visible, "Richard is hidden before discovery")
			var bigo = level.players[1]
			bigo.global_position = Vector2(1300, 625)
			bigo.velocity = Vector2.ZERO
			await frames(5)
			key(KEY_D, true)
			await frames(70)
			key(KEY_D, false)
			await frames(25)
			check(bigo.position.x > 1450 and bigo.position.y > 680, "Player physically enters the hole by walking")
			bigo.global_position = Vector2(1785, 850)
			bigo.velocity = Vector2.ZERO
			await frames(100)
			check(level.richard.state == 2 and level.richard.rabbit.visible, "Real proximity triggers Richard emerging from the burrow")
			check(not level.richard.appear(), "Surprise happens only once per visit")
			check(not "richard" in state.rescued_dogs, "Richard is a rabbit, not a rescued dog")
			key(KEY_D, true)
			for i in range(260):
				if bigo.is_on_floor() and bigo.is_on_wall():
					key(KEY_V, true)
				else:
					key(KEY_V, false)
				await frames(1)
			key(KEY_D, false)
			key(KEY_V, false)
			check(bigo.position.x > 2250 and bigo.position.y < 630, "Player exits the hole via real stairs and jumps")
			level.sloth.global_position = Vector2(1770, 850)
			level.sloth.velocity = Vector2.ZERO
			await frames(5)
			key(KEY_K, true)
			for i in range(480):
				key(KEY_U, level.sloth.is_on_floor() and level.sloth.is_on_wall())
				await frames(1)
			key(KEY_K, false)
			key(KEY_U, false)
			if level.sloth.position.x <= 2250 or level.sloth.position.y >= 630:
				print("SLOTH_EXIT_DEBUG: ", level.sloth.position, " floor:", level.sloth.is_on_floor(), " wall:", level.sloth.is_on_wall())
			check(level.sloth.position.x > 2250 and level.sloth.position.y < 630, "Slower sloth also exits the cave using K and U only")
		for waiting in level.rescue_dogs:
			if is_instance_valid(waiting) and not waiting.is_rescued:
				level.players[0].global_position = waiting.position
				level.players[0].velocity = Vector2.ZERO
				await frames(50)
		check(state.can_finish_level(index) and level.followers.dogs.size() == (7 if index == 3 else 11), "New dogs join the reusable leash formation: " + str(index))
		level.followers.reset_trail()
		var minimum_gap: float = INF
		for i in range(1, level.followers.dogs.size()):
			minimum_gap = minf(minimum_gap, level.followers.dogs[i].position.distance_to(level.followers.dogs[i - 1].position))
		check(minimum_gap > 55.0, "Large dog formation has distinct spaced positions: " + str(index))
		check(level.request_exit(), "New castle progresses: " + str(index))
		await frames(15)
	check(state.finished and state.completed_levels == [0, 1, 2, 3, 4], "All five castles completed and final state saved")
	check(current_scene.name == "FestaDosAmigos", "Celebration scene loads with all dogs")
	check(state.load_progress() and state.rescued_dogs.size() == 11 and state.finished and state.poop_collected == 1, "Rescues, collection count and completion load from disk")
	var file = FileAccess.open(state.save_path, FileAccess.WRITE)
	file.store_string("{invalid")
	file.close()
	check(not state.load_progress() and state.rescued_dogs.size() == 11, "Corrupt save is handled without losing in-memory progress")
	file = FileAccess.open(state.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": 1, "current_level": 2, "unlocked_level": 2, "completed_levels": [0,1,2], "rescued_dogs": ["fofins", "amigo_provisorio"], "finished": true}))
	file.close()
	check(state.load_progress() and state.current_level == 3 and state.unlocked_level == 3 and not state.finished, "Old completed save unlocks new expansion")
	check(state.rescued_dogs == ["fofins", "tokio"], "Old provisional dog save migrates to Tokio without losing Fófins")
	var old_dogs: Array = Catalog.DOGS.keys().filter(func(id): return id != "snoopy")
	# Keep Fófins first in this representative v2 save.
	old_dogs.erase("fofins")
	old_dogs.push_front("fofins")
	file = FileAccess.open(state.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": 2, "current_level": 4, "unlocked_level": 4, "completed_levels": [0,1,2,3,4], "rescued_dogs": old_dogs, "finished": true, "poop_collected": 7}))
	file.close()
	check(state.load_progress() and state.current_level == 3 and state.completed_levels == [0,1,2] and not state.finished, "Old v2 completion returns to Snoopy's newly expanded castle")
	check(state.rescued_dogs.size() == 10 and state.poop_collected == 7, "Migration preserves all previous dogs and collection totals")
	var good_path: String = state.save_path
	state.save_path = "user://missing_test_folder/save.json"
	check(not state.save_progress() and not state.saving_available, "Unavailable storage is reported and play remains possible")
	state.save_path = good_path
	state.new_adventure()
	check(state.rescued_dogs.is_empty() and state.current_level == 0 and not state.finished, "Restart clears adventure progress")
	check(state.saving_available and state.save_notice.is_empty(), "Storage recovery clears an outdated warning")
	DirAccess.remove_absolute(state.save_path)
	print("ADVENTURE_TEST_SUMMARY: ", checks, " checks, ", failures.size(), " failures")
	quit(0 if failures.is_empty() else 1)
