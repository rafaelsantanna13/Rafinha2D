extends "res://adventure/actors/player.gd"

var collector: Node2D
var collect_time: float = 0.0
var catching_up: bool = false
var sloth_frames: Dictionary = {}

func _ready() -> void:
	can_auto_follow = true
	allow_recovery = true
	move_speed = 180.0
	super._ready()
	for frame in ["idle", "walk", "collect", "jump"]:
		sloth_frames[frame] = load("res://adventure/art/sloth_" + frame + ".svg")
	# All sloth frames have the same canvas, so switching never changes size.
	sprite.scale = Vector2.ONE * (art_height / 170.0)
	sprite.position.y = -art_height * 0.5

func _physics_process(delta: float) -> void:
	# Manual input always wins; catch up only when forgotten near a screen edge.
	var manual_input: bool = Input.get_axis(left_action, right_action) != 0.0 or Input.is_action_pressed(jump_action) or Input.is_action_pressed("sloth_collect")
	move_speed = 360.0 if catching_up and manual_time <= 0.0 and not manual_input else 180.0
	super._physics_process(delta)
	collect_time = maxf(0.0, collect_time - delta)
	if Input.is_action_just_pressed("sloth_collect"):
		manual_time = 0.7
		took_control.emit(self)
		if is_instance_valid(collector) and collector.collect_near(self):
			collect_time = 0.55
	var frame: String = "collect" if collect_time > 0.0 else ("jump" if not is_on_floor() else ("walk" if absf(velocity.x) > 8.0 and sin(walk_time * 2.0) > 0.0 else "idle"))
	sprite.texture = sloth_frames[frame]
	sprite.rotation = sin(collect_time * 14.0) * 0.10 if collect_time > 0.0 else sprite.rotation
