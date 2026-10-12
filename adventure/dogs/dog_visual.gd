extends Node2D

var art_id: String = "fofins"
var state: String = "idle"
var poop_time: float = 0.0
var facing: float = 1.0
var time: float = 0.0
var textures: Dictionary = {}
var sprite: Sprite2D

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.position = Vector2(0, -40)
	add_child(sprite)
	for frame in ["idle", "walk", "rescue", "follow"]:
		textures[frame] = load("res://adventure/art/" + art_id + "_" + frame + ".svg")
	sprite.texture = textures["idle"]

func animate(delta: float, moving: bool, celebrating: bool = false) -> void:
	time += delta
	poop_time = maxf(0.0, poop_time - delta)
	state = "rescue" if celebrating else ("walk" if moving and sin(time * 14.0) > 0.0 else ("follow" if moving else "idle"))
	sprite.texture = textures[state]
	sprite.flip_h = facing < 0.0
	sprite.position.y = -40.0 - (absf(sin(time * 7.0)) * 3.0 if moving or celebrating else sin(time * 2.0) * 0.7)
	sprite.rotation = sin(time * 14.0) * 0.025 if moving else 0.0
	sprite.scale.y = 0.85 if poop_time > 0.0 else lerpf(sprite.scale.y, 1.0, minf(1.0, delta * 8.0))
	if poop_time > 0.0:
		sprite.position.y += 5.0

func collar_position() -> Vector2:
	return global_position + Vector2(facing * 28.0, -17.0)
