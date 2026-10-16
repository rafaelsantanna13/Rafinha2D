extends Node2D

var collected: bool = false
var age: float = 0.0
var sprite: Sprite2D
var prompt: Label

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = preload("res://adventure/art/poop.svg")
	sprite.position.y = -19
	add_child(sprite)
	prompt = Label.new()
	prompt.text = "I: recolher"
	prompt.position = Vector2(-70, -67)
	prompt.size.x = 140
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_font_size_override("font_size", 18)
	prompt.add_theme_color_override("font_color", Color("#243449"))
	prompt.add_theme_color_override("font_shadow_color", Color.WHITE)
	prompt.add_theme_constant_override("shadow_offset_x", 1)
	prompt.add_theme_constant_override("shadow_offset_y", 1)
	prompt.hide()
	add_child(prompt)
	sprite.scale = Vector2(0.3, 0.3)
	create_tween().tween_property(sprite, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _physics_process(delta: float) -> void:
	age += delta

func collect() -> bool:
	if collected:
		return false
	collected = true
	prompt.hide()
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "position:y", -55.0, 0.25)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.25)
	tween.chain().tween_callback(queue_free)
	return true
