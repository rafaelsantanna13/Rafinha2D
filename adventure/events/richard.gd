extends Area2D

signal discovered

enum State { HIDDEN, APPEARING, VISIBLE }
var state: State = State.HIDDEN
var rabbit: Sprite2D
var name_label: Label
var appearance_time: float = 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(230, 150)
	collision.shape = shape
	collision.position.y = -65
	add_child(collision)
	var burrow = Sprite2D.new()
	burrow.texture = preload("res://adventure/art/burrow.svg")
	burrow.position = Vector2(0, -30)
	burrow.z_index = 0
	add_child(burrow)
	rabbit = Sprite2D.new()
	rabbit.texture = preload("res://adventure/art/richard.svg")
	rabbit.z_index = 3
	rabbit.position = Vector2(0, -15)
	rabbit.hide()
	add_child(rabbit)
	var rim = Sprite2D.new()
	rim.texture = preload("res://adventure/art/burrow_rim.svg")
	rim.position = Vector2(0, -17)
	rim.z_index = 4
	add_child(rim)
	name_label = Label.new()
	name_label.text = "Richard"
	name_label.z_index = 4
	name_label.position = Vector2(-65, -187)
	name_label.size.x = 130
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", Color("#243449"))
	name_label.add_theme_color_override("font_shadow_color", Color.WHITE)
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	name_label.hide()
	add_child(name_label)

func _physics_process(delta: float) -> void:
	if state == State.HIDDEN:
		for body in get_overlapping_bodies():
			if body.is_in_group("adventure_players") and (not body.automatic_follow or body.manual_time > 0.0):
				appear()
				break
	elif state == State.APPEARING:
		appearance_time += delta
		var progress: float = minf(appearance_time / 1.2, 1.0)
		rabbit.position.y = lerpf(-15.0, -79.0, progress) - sin(progress * PI) * 36.0
		rabbit.rotation = sin(progress * PI * 4.0) * 0.08
		rabbit.modulate.a = minf(1.0, progress * 4.0)
		if progress >= 1.0:
			state = State.VISIBLE
			rabbit.rotation = 0.0

func appear() -> bool:
	if state != State.HIDDEN:
		return false
	state = State.APPEARING
	rabbit.show()
	name_label.show()
	discovered.emit()
	return true
