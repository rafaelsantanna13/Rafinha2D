extends Node2D

const Catalog = preload("res://adventure/catalog.gd")
const UI = preload("res://adventure/ui.gd")
const Player = preload("res://adventure/actors/player.tscn")
const RescueDog = preload("res://adventure/dogs/rescue_dog.tscn")
const Followers = preload("res://adventure/dogs/followers.gd")
const WORLD_WIDTH: float = 2500.0
const FLOOR_Y: float = 625.0

@export var level_index: int = 0
var data: Dictionary
var players: Array[CharacterBody2D] = []
var active_actor: CharacterBody2D
var followers: Node2D
var rescue_dog: Area2D
var camera: Camera2D
var hud: CanvasLayer
var dog_label: Label
var objective: Label
var toast: Label
var guide_label: Label
var help: Control
var gateway: Area2D
var stars: Array[Area2D] = []
var collected_stars: int = 0
var transition_pending: bool = false
var toast_time: float = 0.0
var exit_cooldown: float = 0.0

func _ready() -> void:
	data = Catalog.LEVELS[level_index]
	_build_scenery()
	_build_players()
	followers = Followers.new()
	followers.name = "DogsWithLeashes"
	add_child(followers)
	_update_leader()
	for id in AdventureState.rescued_dogs:
		followers.add_dog(id)
	var dog_id: String = data["dog"]
	if not dog_id.is_empty() and not dog_id in AdventureState.rescued_dogs:
		rescue_dog = RescueDog.instantiate()
		rescue_dog.dog_id = dog_id
		rescue_dog.position = Vector2(1190 if level_index == 0 else 1135, 405)
		rescue_dog.rescued.connect(_on_dog_rescued)
		add_child(rescue_dog)
	if level_index == Catalog.LEVELS.size() - 1:
		for point in [Vector2(505, 520), Vector2(720, 465), Vector2(1150, 355)]:
			_add_star(point)
	_build_gateway()
	_build_hud()
	_update_hud()
	show_message("Bigo e os amigos estão prontos. Vamos juntos!", 4.0)
	print("ADVENTURE_LEVEL_READY:", level_index)

func _build_scenery() -> void:
	var background = Polygon2D.new()
	background.polygon = PackedVector2Array([Vector2(-1000, -1000), Vector2(3500, -1000), Vector2(3500, 1200), Vector2(-1000, 1200)])
	background.color = data["sky"]
	background.z_index = -10
	add_child(background)
	var castle = Sprite2D.new()
	castle.texture = load("res://adventure/art/castle_" + str(level_index + 1) + ".svg")
	castle.position = Vector2(WORLD_WIDTH * 0.5, 320)
	castle.z_index = -8
	add_child(castle)
	var sun = Sprite2D.new()
	sun.texture = preload("res://Sol.svg")
	sun.scale = Vector2(0.20, 0.20)
	sun.position = Vector2(220, 145)
	sun.z_index = -7
	add_child(sun)
	_add_platform(Vector4(0, FLOOR_Y, WORLD_WIDTH, 140))
	for platform in data["steps"]:
		_add_platform(platform)
	for platform in [Vector4(1480, 570, 175, 55), Vector4(1745, 570, 170, 55)]:
		_add_platform(platform)
	var grass = Sprite2D.new()
	grass.texture = preload("res://Mato.svg")
	grass.scale = Vector2(WORLD_WIDTH / grass.texture.get_width(), 1.0)
	grass.position = Vector2(WORLD_WIDTH * 0.5, FLOOR_Y + 4)
	grass.z_index = 2
	add_child(grass)
	queue_redraw()

func _add_platform(rect: Vector4) -> void:
	var body = StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(rect.z, rect.w)
	collision.shape = shape
	collision.position = Vector2(rect.x + rect.z / 2.0, rect.y + rect.w / 2.0)
	body.add_child(collision)
	add_child(body)

func _draw() -> void:
	if data.is_empty():
		return
	draw_rect(Rect2(0, FLOOR_Y, WORLD_WIDTH, 160), Color("#92c572"))
	draw_line(Vector2(0, FLOOR_Y), Vector2(WORLD_WIDTH, FLOOR_Y), Color("#3b5141"), 5.0)
	var ledges: Array = data["steps"].duplicate()
	ledges.append_array([Vector4(1480, 570, 175, 55), Vector4(1745, 570, 170, 55)])
	for platform in ledges:
		var rect = Rect2(platform.x, platform.y, platform.z, platform.w)
		draw_rect(rect, data["stone"])
		draw_rect(rect, Color("#4c3b48"), false, 4.0)
		for x in range(int(rect.position.x) + 35, int(rect.end.x), 55):
			draw_line(Vector2(x, rect.position.y + 7), Vector2(x, rect.end.y - 6), Color("#96839a"), 2.0)
	for i in range(36):
		var flower: Vector2 = Vector2(60 + i * 68, FLOOR_Y + 37 + (i % 3) * 20)
		draw_line(flower, flower + Vector2(0, 14), Color("#467c46"), 3.0)
		draw_circle(flower, 5.0, Color("#fff1b4") if i % 2 == 0 else Color("#f37fa6"))

func _build_players() -> void:
	var settings: Array = [
		["Rafinha", "ui_left", "ui_right", "ui_accept", preload("res://1760301079346.svg"), 132.0, Vector2(260, FLOOR_Y)],
		["Bigo", "Bigoesquerda", "Bigodireita", "Bigopula", preload("res://Bigo2.svg"), 120.0, Vector2(355, FLOOR_Y)],
		["Marina", "esquerdamarina", "direitamarina", "pulamarina", preload("res://Marina.svg"), 130.0, Vector2(170, FLOOR_Y)],
	]
	for entry in settings:
		var actor = Player.instantiate()
		actor.name = entry[0]
		actor.actor_name = entry[0]
		actor.left_action = entry[1]
		actor.right_action = entry[2]
		actor.jump_action = entry[3]
		actor.art = entry[4]
		actor.art_height = entry[5]
		actor.position = entry[6]
		actor.world_width = WORLD_WIDTH
		actor.took_control.connect(_take_control)
		add_child(actor)
		players.append(actor)
	active_actor = players[0]
	camera = Camera2D.new()
	camera.position = Vector2(640, 360)
	camera.limit_left = 0
	camera.limit_right = int(WORLD_WIDTH)
	camera.limit_top = 0
	camera.limit_bottom = 720
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	add_child(camera)

func _take_control(actor: CharacterBody2D) -> void:
	active_actor = actor

func _update_leader() -> void:
	for actor in players:
		if actor.actor_name == AdventureState.leader_name:
			followers.set_leader(actor)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(active_actor) or transition_pending:
		return
	camera.position = active_actor.global_position + Vector2(100, -245)
	for actor in players:
		actor.automatic_follow = AdventureState.assist_friends and actor != active_actor
		actor.automatic_target = formation_target(actor)
		if actor.automatic_follow and actor.manual_time <= 0.0 and actor.global_position.distance_to(active_actor.global_position) > 750.0:
			actor.global_position = active_actor.global_position - Vector2(active_actor.face * 90, 5)
			actor.velocity = Vector2.ZERO
	exit_cooldown = maxf(0.0, exit_cooldown - delta)
	if toast_time > 0.0:
		toast_time -= delta
		toast.visible = toast_time > 0.0
	for body in gateway.get_overlapping_bodies():
		if body.is_in_group("adventure_players") and exit_cooldown <= 0.0:
			if not request_exit():
				exit_cooldown = 2.0
			break
	_update_web_probe()

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_H, KEY_ESCAPE:
			_toggle_help()
		KEY_T:
			AdventureState.assist_friends = not AdventureState.assist_friends
			AdventureState.save_progress()
			show_message("Os amigos acompanham você." if AdventureState.assist_friends else "Cada personagem anda com suas próprias teclas.")
		KEY_C:
			_regroup()

func _regroup() -> void:
	for actor in players:
		if actor != active_actor:
			actor.global_position = formation_target(actor) - Vector2(0, 5)
			actor.velocity = Vector2.ZERO
	followers.reset_trail()
	show_message("Todo mundo junto outra vez!")

func formation_target(actor: CharacterBody2D) -> Vector2:
	var offset: float = 0.0
	if actor.actor_name == AdventureState.leader_name:
		offset = -130.0
	elif active_actor.actor_name == AdventureState.leader_name:
		var other_names: Array[String] = []
		for friend in players:
			if friend != active_actor:
				other_names.append(friend.actor_name)
		offset = 115.0 + other_names.find(actor.actor_name) * 115.0
	else:
		offset = 115.0
	return active_actor.global_position + Vector2(active_actor.face * offset, 0)

func _on_dog_rescued(id: String) -> void:
	followers.add_dog(id, true)
	_update_hud()
	show_message("Fófins resgatada! " + AdventureState.leader_name + " segura a guia." if id == "fofins" else "Mais um amigo resgatado! Os dois vêm com vocês.", 5.0)
	print("ADVENTURE_RESCUED:", id)

func _add_star(point: Vector2) -> void:
	var star = Area2D.new()
	star.position = point
	star.collision_layer = 0
	star.collision_mask = 2
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 44.0
	shape.shape = circle
	star.add_child(shape)
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://adventure/art/paw.svg")
	star.add_child(sprite)
	star.body_entered.connect(func(body: Node2D):
		if body.is_in_group("adventure_players"):
			collect_star(star)
	)
	add_child(star)
	stars.append(star)

func collect_star(star: Area2D) -> bool:
	if not is_instance_valid(star) or not stars.has(star) or star.get_meta("collected", false) or followers.dogs.is_empty():
		return false
	star.set_meta("collected", true)
	star.visible = false
	star.set_deferred("monitoring", false)
	collected_stars += 1
	_update_hud()
	show_message("Patinha encontrada! " + str(collected_stars) + " de 3")
	return true

func _build_gateway() -> void:
	gateway = Area2D.new()
	gateway.position = Vector2(2270, FLOOR_Y)
	gateway.collision_layer = 0
	gateway.collision_mask = 2
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(120, 170)
	collision.shape = shape
	collision.position.y = -85
	gateway.add_child(collision)
	var art = Sprite2D.new()
	art.texture = preload("res://adventure/art/gate.svg")
	art.position.y = -85
	gateway.add_child(art)
	var label = UI.label("A FESTA!" if level_index == 2 else "PRÓXIMO CASTELO", 22)
	label.position = Vector2(-150, -212)
	label.size.x = 300
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gateway.add_child(label)
	add_child(gateway)

func request_exit() -> bool:
	if transition_pending:
		return false
	if not AdventureState.can_finish_level(level_index):
		show_message("Vamos resgatar " + Catalog.DOGS[data["dog"]]["name"] + " primeiro!")
		return false
	if level_index == 2 and collected_stars < 3:
		show_message("Faltam " + str(3 - collected_stars) + " patinhas. Vamos procurar juntos!")
		return false
	if not AdventureState.complete_level(level_index):
		return false
	transition_pending = true
	var target: String = "res://adventure/celebration.tscn" if AdventureState.finished else Catalog.scene_for(AdventureState.current_level)
	get_tree().call_deferred("change_scene_to_file", target)
	return true

func _build_hud() -> void:
	hud = CanvasLayer.new()
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(hud)
	var top = UI.panel()
	top.position = Vector2(18, 16)
	top.size = Vector2(930, 92)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(top)
	var rows = VBoxContainer.new()
	top.add_child(rows)
	rows.add_child(UI.label("CASTELO " + str(level_index + 1) + " / " + str(Catalog.LEVELS.size()) + "    " + data["title"], 25))
	dog_label = UI.label("", 21)
	rows.add_child(dog_label)
	var help_button = UI.button("AJUDA (H)", _toggle_help)
	help_button.position = Vector2(1065, 20)
	help_button.size = Vector2(195, 60)
	hud.add_child(help_button)
	guide_label = UI.label("", 19)
	guide_label.position = Vector2(18, 116)
	hud.add_child(guide_label)
	var bottom = UI.panel()
	bottom.position = Vector2(18, 647)
	bottom.size = Vector2(1244, 57)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(bottom)
	objective = UI.label("", 23)
	bottom.add_child(objective)
	var toast_panel = UI.panel()
	toast_panel.position = Vector2(175, 142)
	toast_panel.size = Vector2(930, 56)
	toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(toast_panel)
	toast = UI.label("", 24)
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_panel.add_child(toast)
	toast.visibility_changed.connect(func(): toast_panel.visible = toast.visible)
	help = Control.new()
	help.focus_mode = Control.FOCUS_ALL
	help.gui_input.connect(func(event: InputEvent):
		if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode in [KEY_H, KEY_ESCAPE]:
			_toggle_help()
			help.accept_event()
	)
	help.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.add_child(help)
	var shade = ColorRect.new()
	shade.color = Color(0.12, 0.14, 0.23, 0.6)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	help.add_child(shade)
	var panel = UI.panel()
	panel.position = Vector2(250, 95)
	panel.size = Vector2(780, 530)
	help.add_child(panel)
	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	panel.add_child(layout)
	layout.add_child(UI.label("VAMOS JOGAR JUNTOS!", 30))
	layout.add_child(UI.label("Rafinha: setas esquerda/direita    Espaço: pular", 23))
	layout.add_child(UI.label("Bigo: A / D: andar    V: pular    E: pum", 23))
	layout.add_child(UI.label("Marina: 1 / 3: andar    L: pular", 23))
	layout.add_child(UI.label("Resgate: fique pertinho do cachorro.\nT: liga/desliga a ajuda dos amigos.    C: reunir amigos.", 21))
	layout.add_child(UI.button("TROCAR QUEM SEGURA AS GUIAS", _switch_guide))
	layout.add_child(UI.button("CONTINUAR JOGANDO", _toggle_help, true))
	layout.add_child(UI.button("VOLTAR AO MENU", _return_to_menu))
	help.hide()

func _switch_guide() -> void:
	AdventureState.leader_name = "Bigo" if AdventureState.leader_name == "Rafinha" else "Rafinha"
	AdventureState.save_progress()
	_update_leader()
	_update_hud()

func _toggle_help() -> void:
	help.visible = not help.visible
	get_tree().paused = help.visible
	if help.visible:
		help.grab_focus()
	else:
		help.release_focus()

func _return_to_menu() -> void:
	get_tree().paused = false
	AdventureState.save_progress()
	get_tree().change_scene_to_file("res://menu_inicial.tscn")

func _update_hud() -> void:
	var names: PackedStringArray = []
	for id in AdventureState.rescued_dogs:
		names.append(Catalog.DOGS[id]["name"])
	dog_label.text = "Cachorros: " + str(names.size()) + ("    " + ", ".join(names) if not names.is_empty() else "    Vamos encontrar a Fófins!")
	guide_label.text = AdventureState.leader_name + " conduz os cachorros pelas guias"
	if level_index == 2:
		objective.text = "Patinhas: " + str(collected_stars) + " / 3. " + ("Agora vá até a festa!" if collected_stars == 3 else "Suba as plataformas com os amigos.")
	elif AdventureState.can_finish_level(level_index):
		objective.text = "Cachorro resgatado! Vá para a porta do próximo castelo."
	else:
		objective.text = data["hint"]
	if not AdventureState.save_notice.is_empty():
		guide_label.text += "    Progresso só nesta sessão."

func show_message(message: String, duration: float = 3.0) -> void:
	toast.text = message
	toast.visible = true
	toast_time = duration

func _update_web_probe() -> void:
	# Read-only state for browser tests. It provides no game shortcuts.
	if not OS.has_feature("web") or Engine.get_physics_frames() % 15 != 0:
		return
	var actors: Dictionary = {}
	var floors: Dictionary = {}
	for actor in players:
		actors[actor.actor_name] = [snappedf(actor.position.x, 0.1), snappedf(actor.position.y, 0.1)]
		floors[actor.actor_name] = actor.is_on_floor()
	var dog_positions: Array = []
	for dog in followers.dogs:
		dog_positions.append([snappedf(dog.position.x, 0.1), snappedf(dog.position.y, 0.1)])
	var value: String = JSON.stringify({"level": level_index, "actors": actors, "floors": floors, "dogs": followers.dog_ids,
		"dog_positions": dog_positions, "leader": AdventureState.leader_name, "stars": collected_stars})
	JavaScriptBridge.eval("window.rafinhaAdventure = " + value, true)
