extends CharacterBody2D

var defeated: bool = false
var reaction: String = ""
var reaction_time: float = 0.0
var walk_time: float = 0.0
var home_x: float = 0.0
var patrol_width: float = 18.0
var sprite: Sprite2D
var label: Label

func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	home_x = position.x
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(46, 92)
	collision.shape = shape
	collision.position.y = -46
	add_child(collision)
	sprite = Sprite2D.new()
	sprite.texture = preload("res://adventure/art/bighead.svg")
	sprite.position.y = -53
	add_child(sprite)
	label = Label.new()
	label.text = "Cabeçudinho"
	label.position = Vector2(-80, -141)
	label.size.x = 160
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color("#493451"))
	label.add_theme_color_override("font_shadow_color", Color.WHITE)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(label)

func _physics_process(delta: float) -> void:
	walk_time += delta
	if not is_on_floor():
		velocity += get_gravity() * delta
	if defeated:
		reaction_time += delta
		velocity.x = move_toward(velocity.x, 0.0, delta * 130.0)
		sprite.rotation = sin(reaction_time * 7.0) * 0.08
		if reaction == "judo" and reaction_time < 0.7:
			sprite.rotation = reaction_time / 0.7 * TAU
	else:
		velocity.x = cos(walk_time * 1.3) * 22.0
		if absf(position.x - home_x) > patrol_width:
			velocity.x = signf(home_x - position.x) * 22.0
		sprite.rotation = sin(walk_time * 5.0) * 0.04
	move_and_slide()
	queue_redraw()

func react(kind: String, direction: float) -> bool:
	if defeated:
		return false
	defeated = true
	reaction = kind
	# A comic tumble opens the passage; nobody loses health or lives.
	collision_layer = 0
	velocity = Vector2(direction * (340.0 if kind == "force" else 220.0), -250.0 if kind == "judo" else -140.0)
	label.text = "Ué?!"
	return true

func _draw() -> void:
	if not defeated:
		return
	for i in range(3):
		var angle: float = reaction_time * 3.0 + i * TAU / 3.0
		var point = Vector2(cos(angle) * 27.0, -115.0 + sin(angle) * 7.0)
		draw_circle(point, 4, Color("#ffd558"))
		draw_line(point - Vector2(7, 0), point + Vector2(7, 0), Color("#fff5a1"), 2)
