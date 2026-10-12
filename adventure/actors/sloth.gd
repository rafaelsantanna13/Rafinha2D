extends "res://adventure/actors/player.gd"

var collector: Node2D
var collect_time: float = 0.0
var sloth_frames: Dictionary = {}

func _ready() -> void:
	can_auto_follow = false
	allow_recovery = false
	move_speed = 180.0
	super._ready()
	for frame in ["idle", "walk", "collect", "jump"]:
		sloth_frames[frame] = load("res://adventure/art/sloth_" + frame + ".svg")
	# All sloth frames have the same canvas, so switching never changes size.
	sprite.scale = Vector2.ONE * (art_height / 170.0)
	sprite.position.y = -art_height * 0.5

func _physics_process(delta: float) -> void:
	# This actor has no follow target, regroup or off-screen teleport.
	automatic_follow = false
	super._physics_process(delta)
	collect_time = maxf(0.0, collect_time - delta)
	if Input.is_action_just_pressed("sloth_collect"):
		took_control.emit(self)
		if is_instance_valid(collector) and collector.collect_near(self):
			collect_time = 0.55
	var frame: String = "collect" if collect_time > 0.0 else ("jump" if not is_on_floor() else ("walk" if absf(velocity.x) > 8.0 and sin(walk_time * 2.0) > 0.0 else "idle"))
	sprite.texture = sloth_frames[frame]
	sprite.rotation = sin(collect_time * 14.0) * 0.10 if collect_time > 0.0 else sprite.rotation
