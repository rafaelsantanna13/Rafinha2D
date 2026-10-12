extends Node2D

const Catalog = preload("res://adventure/catalog.gd")
const UI = preload("res://adventure/ui.gd")
const Player = preload("res://adventure/actors/player.tscn")
const RescueDog = preload("res://adventure/dogs/rescue_dog.tscn")
const Followers = preload("res://adventure/dogs/followers.gd")
const Sloth = preload("res://adventure/actors/sloth.tscn")
const PoopManager = preload("res://adventure/poop/manager.gd")
const Abilities = preload("res://adventure/combat/abilities.gd")
const Bighead = preload("res://adventure/combat/bighead.gd")
var combat: Node2D
var guilherme: CharacterBody2D
const RichardEvent = preload("res://adventure/events/richard.gd")
var world_width: float = 2500.0
var ground_rects: Array[Vector4] = []
var rescue_dogs: Array[Area2D] = []
var sloth: CharacterBody2D
var poop: Node2D
var richard: Area2D
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
	world_width = data["width"]
	ground_rects = [Vector4(0, FLOOR_Y, world_width, 140)]
	if data.get("cave", false):
		ground_rects = [Vector4(0, FLOOR_Y, 1400, 350), Vector4(2220, FLOOR_Y, world_width - 2220, 350), Vector4(1400, 850, 820, 125)]
	_build_scenery()
	_build_players()
	combat = Abilities.new()
	add_child(combat)
	var encounters: Array = [
		[Vector2(1450, 625)], [Vector2(1360, 625), Vector2(1980, 625)],
		[Vector2(1450, 625)], [Vector2(875, 625), Vector2(1550, 625), Vector2(2230, 625)],
		[Vector2(1020, 625), Vector2(2380, 625)],
	]
	for point in encounters[level_index]:
		var villain = Bighead.new()
		villain.position = point
		villain.z_index = 3
		add_child(villain)
		combat.villains.append(villain)
	for actor in players:
		actor.combat = combat
	combat.performed.connect(func(kind: String, hits: int):
		show_message(("Judô misterioso! Rodopiou!" if kind == "judo" else "Guilherme usou a Força! Caminho livre!") if hits > 0 else ("Chegue mais perto e use F para o judô." if kind == "judo" else "Aponte a Força para um cabeçudinho próximo."), 2.0)
	)
	followers = Followers.new()
	followers.name = "DogsWithLeashes"
	followers.z_index = 3
	add_child(followers)
	_update_leader()
	for id in AdventureState.rescued_dogs:
		followers.add_dog(id)
	for dog_id in data["rescues"]:
		if dog_id in AdventureState.rescued_dogs:
			continue
		var waiting_dog = RescueDog.instantiate()
		waiting_dog.dog_id = dog_id
		waiting_dog.z_index = 3
		waiting_dog.position = data["rescues"][dog_id]
		waiting_dog.rescued.connect(_on_dog_rescued)
		add_child(waiting_dog)
		rescue_dogs.append(waiting_dog)
		if rescue_dog == null:
			rescue_dog = waiting_dog
	if data.get("paws", false):
		for point in [Vector2(505, 520), Vector2(720, 465), Vector2(1150, 355)]:
			_add_star(point)
	poop = PoopManager.new()
	poop.z_index = 3
	poop.followers = followers
	poop.sloth = sloth
	poop.picked_up.connect(func(total: int):
		_update_hud()
		show_message("Oba! Cocô recolhido! Total: " + str(total), 2.5)
	)
	add_child(poop)
	sloth.collector = poop
	if data.get("cave", false):
		richard = RichardEvent.new()
		richard.position = Vector2(1785, 850)
		richard.discovered.connect(func(): show_message("Surpresa! Oi, Richard!", 5.0))
		add_child(richard)
	_build_gateway()
	_build_hud()
	_update_hud()
	show_message("Bigo e os amigos estão prontos. Vamos juntos!", 4.0)
	print("ADVENTURE_LEVEL_READY:", level_index)

func _build_scenery() -> void:
	var background = Polygon2D.new()
	background.polygon = PackedVector2Array([Vector2(-1000, -1000), Vector2(world_width + 1000, -1000), Vector2(world_width + 1000, 1200), Vector2(-1000, 1200)])
	background.color = data["sky"]
	background.z_index = -10
	add_child(background)
	var castle = Sprite2D.new()
	castle.texture = load("res://adventure/art/castle_" + str(level_index + 1) + ".svg")
	castle.position = Vector2(world_width * 0.5, 320)
	castle.scale.x = world_width / 2500.0
	castle.z_index = -8
	add_child(castle)
	var sun = Sprite2D.new()
	sun.texture = preload("res://Sol.svg")
	sun.scale = Vector2(0.20, 0.20)
	sun.position = Vector2(220, 145)
	sun.z_index = -7
	add_child(sun)
	for ground in ground_rects:
		_add_platform(ground)
	for platform in data["steps"]:
		_add_platform(platform)
	for ground in ground_rects:
		if ground.y != FLOOR_Y:
			continue
		var grass = Sprite2D.new()
		grass.texture = preload("res://Mato.svg")
		grass.scale = Vector2(ground.z / grass.texture.get_width(), 1.0)
		grass.position = Vector2(ground.x + ground.z * 0.5, FLOOR_Y + 4)
		grass.z_index = 2
		add_child(grass)
	if data.has("house"):
		var house = Sprite2D.new()
		house.texture = preload("res://adventure/art/snoopy_house.svg")
		house.position = data["house"] - Vector2(0, 90)
		house.z_index = 1
		add_child(house)
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
	if data.get("cave", false):
		draw_rect(Rect2(1400, FLOOR_Y, 820, 350), Color("#efd4ae"))
		draw_rect(Rect2(1420, FLOOR_Y + 15, 780, 210), Color("#e3bc8f"))
		for i in range(12):
			draw_circle(Vector2(1440 + i * 63, 820), 4, Color("#bb9675"))
	for ground in ground_rects:
		draw_rect(Rect2(ground.x, ground.y, ground.z, ground.w), Color("#92c572") if ground.y == FLOOR_Y else Color("#c5a376"))
		draw_line(Vector2(ground.x, ground.y), Vector2(ground.x + ground.z, ground.y), Color("#3b5141"), 5.0)
	var ledges: Array = data["steps"].duplicate()
	for platform in ledges:
		var rect = Rect2(platform.x, platform.y, platform.z, platform.w)
		draw_rect(rect, data["stone"])
		draw_rect(rect, Color("#4c3b48"), false, 4.0)
		for x in range(int(rect.position.x) + 35, int(rect.end.x), 55):
			draw_line(Vector2(x, rect.position.y + 7), Vector2(x, rect.end.y - 6), Color("#96839a"), 2.0)
	for i in range(36):
		var flower: Vector2 = Vector2(60 + i * 68, FLOOR_Y + 37 + (i % 3) * 20)
		if data.get("cave", false) and flower.x > 1400 and flower.x < 2220:
			continue
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
		actor.z_index = 3
		actor.actor_name = entry[0]
		actor.left_action = entry[1]
		actor.right_action = entry[2]
		actor.jump_action = entry[3]
		actor.art = entry[4]
		actor.art_height = entry[5]
		actor.position = entry[6]
		actor.world_width = world_width
		actor.world_bottom = 1100.0 if data.get("cave", false) else 820.0
		if actor.actor_name == "Rafinha":
			actor.special_action = "rafinha_judo"
			actor.special_kind = "judo"
		actor.took_control.connect(_take_control)
		add_child(actor)
		players.append(actor)
	sloth = Sloth.instantiate()
	sloth.name = "BichoPreguica"
	sloth.z_index = 3
	sloth.art = preload("res://adventure/art/sloth_idle.svg")
	sloth.art_height = 148.0
	sloth.position = Vector2(100, FLOOR_Y)
	sloth.world_width = world_width
	sloth.world_bottom = 1100.0 if data.get("cave", false) else 820.0
	sloth.took_control.connect(_take_control)
	add_child(sloth)
	players.append(sloth)
	guilherme = Player.instantiate()
	guilherme.name = "Guilherme"
	guilherme.actor_name = "Guilherme"
	guilherme.left_action = "guilherme_left"
	guilherme.right_action = "guilherme_right"
	guilherme.jump_action = "guilherme_jump"
	guilherme.special_action = "guilherme_force"
	guilherme.special_kind = "force"
	guilherme.art = preload("res://adventure/art/guilherme_idle.svg")
	guilherme.art_height = 138.0
	guilherme.position = Vector2(510, FLOOR_Y)
	for platform in data["steps"]:
		if 510 >= platform.x and 510 <= platform.x + platform.z:
			guilherme.position.y = minf(guilherme.position.y, platform.y)
	guilherme.world_width = world_width
	guilherme.world_bottom = 1100.0 if data.get("cave", false) else 820.0
	guilherme.z_index = 3
	guilherme.took_control.connect(_take_control)
	add_child(guilherme)
	players.append(guilherme)
	active_actor = players[0]
	camera = Camera2D.new()
	camera.position = Vector2(640, 360)
	camera.limit_left = 0
	camera.limit_right = int(world_width)
	camera.limit_top = 0
	camera.limit_bottom = 1000 if data.get("cave", false) else 720
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
	_update_sloth_follow()
	camera.position = active_actor.global_position + Vector2(100, -245)
	if sloth.catching_up and active_actor != sloth:
		var gap: float = absf(active_actor.position.x - sloth.position.x)
		camera.zoom = Vector2.ONE * minf(1.0, 1280.0 / (gap + 460.0))
		camera.position.x = (active_actor.position.x + sloth.position.x) * 0.5 + 120.0
		camera.position_smoothing_enabled = gap < 550.0
	else:
		camera.zoom = camera.zoom.move_toward(Vector2.ONE, delta * 2.0)
		camera.position_smoothing_enabled = true
	for actor in players:
		if actor == sloth:
			continue
		actor.automatic_follow = actor.can_auto_follow and AdventureState.assist_friends and actor != active_actor
		actor.automatic_target = formation_target(actor)
		if actor.automatic_follow and actor.manual_time <= 0.0 and actor.global_position.distance_to(active_actor.global_position) > 750.0:
			actor.global_position = active_actor.global_position - Vector2(active_actor.face * 90, 5)
			actor.velocity = Vector2.ZERO
	exit_cooldown = maxf(0.0, exit_cooldown - delta)
	if toast_time > 0.0:
		toast_time -= delta
		toast.visible = toast_time > 0.0
	for body in gateway.get_overlapping_bodies():
		if body == active_actor and exit_cooldown <= 0.0:
			if not request_exit():
				exit_cooldown = 2.0
			break
	_update_web_probe()


func visible_world_rect() -> Rect2:
	var size: Vector2 = get_viewport_rect().size / camera.zoom
	return Rect2(camera.get_screen_center_position() - size * 0.5, size)

func sloth_is_visible() -> bool:
	return visible_world_rect().has_point(sloth.position - Vector2(0, sloth.art_height * 0.5))

func _update_sloth_follow() -> void:
	if active_actor == sloth or sloth.manual_time > 0.0:
		sloth.catching_up = false
		sloth.automatic_follow = false
		return
	var view: Rect2 = visible_world_rect()
	var separation: float = absf(active_actor.position.x - sloth.position.x)
	var near_edge: bool = sloth.position.x < view.position.x + 220 or sloth.position.x > view.end.x - 220
	if separation > 320.0 and near_edge:
		sloth.catching_up = true
	if separation < 220.0:
		sloth.catching_up = false
	sloth.automatic_follow = sloth.catching_up
	sloth.automatic_target = active_actor.position - Vector2(active_actor.face * 180.0, 0)

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
		if actor != active_actor and actor != sloth and actor.can_auto_follow:
			actor.global_position = formation_target(actor) - Vector2(0, 5)
			actor.velocity = Vector2.ZERO
	followers.reset_trail()
	show_message("Amigos reunidos! A preguiça vem se ficar para trás.")

func formation_target(actor: CharacterBody2D) -> Vector2:
	var offset: float = 0.0
	if actor.actor_name == AdventureState.leader_name:
		offset = -130.0
	elif active_actor.actor_name == AdventureState.leader_name:
		var other_names: Array[String] = []
		for friend in players:
			if friend != active_actor and friend != sloth and friend.can_auto_follow:
				other_names.append(friend.actor_name)
		offset = 115.0 + other_names.find(actor.actor_name) * 115.0
	else:
		offset = 115.0
	return active_actor.global_position + Vector2(active_actor.face * offset, 0)

func _on_dog_rescued(id: String) -> void:
	followers.add_dog(id, true)
	_update_hud()
	show_message("Snoopy acordou! Vamos juntos com as guias!" if id == "snoopy" else Catalog.DOGS[id]["name"] + (" resgatada! " if Catalog.DOGS[id].get("female", false) else " resgatado! ") + AdventureState.leader_name + " segura as guias.", 4.0)
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
	gateway.position = Vector2(world_width - 230, FLOOR_Y)
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
	var label = UI.label("A FESTA!" if level_index == Catalog.LEVELS.size() - 1 else "PRÓXIMO CASTELO", 22)
	label.position = Vector2(-150, -212)
	label.size.x = 300
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gateway.add_child(label)
	add_child(gateway)

func request_exit() -> bool:
	if transition_pending:
		return false
	if not AdventureState.can_finish_level(level_index):
		show_message("Ainda há cachorros esperando. Vamos resgatar todos!")
		return false
	if data.get("paws", false) and collected_stars < 3:
		show_message("Faltam " + str(3 - collected_stars) + " patinhas. Vamos procurar juntos!")
		return false
	if not AdventureState.complete_level(level_index):
		return false
	transition_pending = true
	poop.stop_and_clear()
	var target: String = "res://adventure/celebration.tscn" if AdventureState.finished else Catalog.scene_for(AdventureState.current_level)
	get_tree().call_deferred("change_scene_to_file", target)
	return true

func _build_hud() -> void:
	hud = CanvasLayer.new()
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(hud)
	var top = UI.panel()
	top.position = Vector2(18, 16)
	top.size = Vector2(1030, 92)
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
	panel.position = Vector2(210, 50)
	panel.size = Vector2(860, 620)
	help.add_child(panel)
	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 8)
	panel.add_child(layout)
	layout.add_child(UI.label("VAMOS JOGAR JUNTOS!", 30))
	layout.add_child(UI.label("Rafinha: setas esquerda/direita    Espaço: pular    F: judô", 23))
	layout.add_child(UI.label("Bigo: A / D: andar    V: pular    E: pum", 23))
	layout.add_child(UI.label("Marina: 1 / 3: andar    L: pular", 23))
	layout.add_child(UI.label("Preguiça: J / K: andar    U: pular    I: recolher cocô", 23))
	layout.add_child(UI.label("Guilherme: Z / X: andar    B: pular    Q: Força", 23))
	layout.add_child(UI.label("F: judô misterioso. Q: afasta cabeçudinhos com a Força.\nPreguiça: use I perto do cocô. Ela vem se ficar na borda.\nResgate: chegue pertinho. T: ajuda dos amigos. C: reunir amigos.", 20))
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
	_update_web_probe(true)
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
	dog_label.text = "Cachorros: " + str(names.size()) + ("    " + ", ".join(names.slice(0, 2)) + (" e mais " + str(names.size() - 2) if names.size() > 2 else "") if not names.is_empty() else "    Vamos encontrar a Fófins!") + "    Cocôs recolhidos: " + str(AdventureState.poop_collected)
	guide_label.text = AdventureState.leader_name + " conduz os cachorros pelas guias"
	if data.get("paws", false):
		objective.text = "Patinhas: " + str(collected_stars) + " / 3. " + ("Agora siga para o próximo castelo!" if collected_stars == 3 else "Suba as plataformas com os amigos.")
	elif AdventureState.can_finish_level(level_index):
		objective.text = "Todos resgatados! Vá até a porta " + ("da festa!" if level_index == Catalog.LEVELS.size() - 1 else "do próximo castelo.")
	else:
		var rescued_here: int = 0
		for id in data["rescues"]:
			if id in AdventureState.rescued_dogs:
				rescued_here += 1
		var hint: String = "Snoopy já vem com vocês! Busque os amigos que ainda esperam." if data.get("main_rescue", "") == "snoopy" and "snoopy" in AdventureState.rescued_dogs else data["hint"]
		objective.text = hint + ("  " + str(rescued_here) + " / " + str(data["rescues"].size()) if data["rescues"].size() > 1 else "")
	if not AdventureState.save_notice.is_empty():
		guide_label.text += "    Progresso só nesta sessão."

func show_message(message: String, duration: float = 3.0) -> void:
	toast.text = message
	toast.visible = true
	toast_time = duration

func _update_web_probe(force: bool = false) -> void:
	# Read-only state for browser tests. It provides no game shortcuts.
	if not OS.has_feature("web") or (not force and Engine.get_physics_frames() % 15 != 0):
		return
	var actors: Dictionary = {}
	var floors: Dictionary = {}
	for actor in players:
		actors[actor.actor_name] = [snappedf(actor.position.x, 0.1), snappedf(actor.position.y, 0.1)]
		floors[actor.actor_name] = actor.is_on_floor()
	var dog_positions: Array = []
	for dog in followers.dogs:
		dog_positions.append([snappedf(dog.position.x, 0.1), snappedf(dog.position.y, 0.1)])
	var poop_positions: Array = []
	for item in poop.objects:
		poop_positions.append([snappedf(item.position.x, 0.1), snappedf(item.position.y, 0.1)])
	var pending: Array = []
	for id in data["rescues"]:
		if not id in AdventureState.rescued_dogs:
			var point: Vector2 = data["rescues"][id]
			var sleeping: bool = false
			for waiting in rescue_dogs:
				if is_instance_valid(waiting) and waiting.dog_id == id:
					sleeping = waiting.visual.is_sleeping
			pending.append({"id": id, "position": [point.x, point.y], "sleeping": sleeping})
	var platforms: Array = []
	for point in data["steps"]:
		platforms.append([point.x, point.y, point.z, point.w])
	var villains: Array = []
	for villain in combat.villains:
		villains.append({"position": [snappedf(villain.position.x, 0.1), snappedf(villain.position.y, 0.1)], "defeated": villain.defeated, "reaction": villain.reaction})
	var value: String = JSON.stringify({"level": level_index, "release": Catalog.CONTENT_VERSION, "actors": actors, "floors": floors, "dogs": followers.dog_ids,
		"dog_positions": dog_positions, "leader": AdventureState.leader_name, "stars": collected_stars,
		"poop": poop_positions, "poop_collected": AdventureState.poop_collected, "poop_generated": poop.generated, "poop_limit": poop.max_objects,
		"pending": pending, "platforms": platforms, "villains": villains, "judo_hits": combat.judo_hits, "force_hits": combat.force_hits, "sloth_following": sloth.catching_up, "sloth_visible": sloth_is_visible(), "exit_x": gateway.position.x, "help": help.visible,
		"help_text": " ".join(help.find_children("*", "Label", true, false).map(func(item): return item.text)),
		"richard": int(richard.state) if is_instance_valid(richard) else -1})
	JavaScriptBridge.eval("window.rafinhaAdventure = " + value, true)
