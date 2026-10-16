extends "res://adventure/actors/player.gd"

# When nobody controls her, the sloth cleans up on her own, very lazily:
# she ignores fresh poop, naps, yawns, shuffles slowly and rests a long time.
enum Chore { RESTING, STRETCHING, WALKING, PICKING }
const LAZY_SPEED: float = 70.0
const NOTICE_AGE: float = 6.0
const STRETCH_TIME: float = 2.2
const PICK_TIME: float = 1.5
const GIVE_UP_TIME: float = 15.0
const REST_AFTER_PICK: Vector2 = Vector2(8.0, 12.0)
const REST_AFTER_CONTROL: float = 4.0
const VIEW_MARGIN: float = 230.0

var collector: Node2D
var collect_time: float = 0.0
var catching_up: bool = false
var sloth_frames: Dictionary = {}
var chore: int = Chore.RESTING
var chore_time: float = REST_AFTER_CONTROL
var chore_target: Node2D
var lazy_pickups: int = 0
var thought: Label

func _ready() -> void:
	can_auto_follow = true
	allow_recovery = true
	move_speed = 180.0
	jump_pitch = 0.8
	super._ready()
	for frame in ["idle", "walk", "collect", "jump"]:
		sloth_frames[frame] = load("res://adventure/art/sloth_" + frame + ".svg")
	# All sloth frames have the same canvas, so switching never changes size.
	sprite.scale = Vector2.ONE * (art_height / 170.0)
	sprite.position.y = -art_height * 0.5
	thought = $Name.duplicate()
	thought.position.y -= 26.0
	thought.add_theme_font_size_override("font_size", 18)
	thought.hide()
	add_child(thought)

func _physics_process(delta: float) -> void:
	# Manual input always wins; catch up only when forgotten near a screen edge.
	var manual_input: bool = Input.get_axis(left_action, right_action) != 0.0 or Input.is_action_pressed(jump_action) or Input.is_action_pressed("sloth_collect")
	var automatic: bool = manual_time <= 0.0 and not manual_input
	move_speed = 360.0 if catching_up and automatic else (LAZY_SPEED if chore == Chore.WALKING and automatic else 180.0)
	super._physics_process(delta)
	collect_time = maxf(0.0, collect_time - delta)
	if Input.is_action_just_pressed("sloth_collect"):
		manual_time = 0.7
		took_control.emit(self)
		if is_instance_valid(collector) and collector.collect_near(self):
			collect_time = 0.55
	var frame: String = "collect" if collect_time > 0.0 or chore == Chore.PICKING else ("jump" if not is_on_floor() else ("walk" if absf(velocity.x) > 8.0 and sin(walk_time * 2.0) > 0.0 else "idle"))
	sprite.texture = sloth_frames[frame]
	sprite.rotation = sin(collect_time * 14.0) * 0.10 if collect_time > 0.0 else sprite.rotation
	if chore == Chore.STRETCHING:
		sprite.rotation = sin(chore_time * 3.0) * 0.08
	_update_thought()

func cancel_chore(rest: float = REST_AFTER_CONTROL) -> void:
	chore = Chore.RESTING
	chore_target = null
	chore_time = maxf(chore_time, rest)

# Called by the level while another character is in control. Returns true
# when the sloth wants to walk towards automatic_target.
func lazy_step(delta: float, view: Rect2) -> bool:
	if not is_instance_valid(collector) or not collector.enabled:
		cancel_chore(1.0)
		return false
	chore_time -= delta
	var target_alive: bool = is_instance_valid(chore_target) and not chore_target.collected
	match chore:
		Chore.RESTING:
			if chore_time > 0.0:
				return false
			chore_target = collector.lazy_target(self, view.grow_individual(-VIEW_MARGIN, 0, -VIEW_MARGIN, 0), NOTICE_AGE)
			if chore_target == null:
				chore_time = 1.5
				return false
			chore = Chore.STRETCHING
			chore_time = STRETCH_TIME
			AdventureAudio.play("yawn")
		Chore.STRETCHING:
			if not target_alive:
				_rest(2.0)
			elif chore_time <= 0.0:
				chore = Chore.WALKING
				chore_time = GIVE_UP_TIME
		Chore.WALKING:
			if not target_alive:
				_rest(2.0)
			elif collector.can_collect(self, chore_target) and absf(chore_target.global_position.x - global_position.x) < 40.0:
				chore = Chore.PICKING
				chore_time = PICK_TIME
			elif chore_time <= 0.0:
				_rest(randf_range(REST_AFTER_PICK.x, REST_AFTER_PICK.y))
			else:
				automatic_target = chore_target.global_position
				return true
		Chore.PICKING:
			if not target_alive:
				_rest(2.0)
			elif chore_time <= 0.0:
				if collector.collect_near(self, true):
					collect_time = 1.1
					lazy_pickups += 1
				_rest(randf_range(REST_AFTER_PICK.x, REST_AFTER_PICK.y))
	return false

func _rest(seconds: float) -> void:
	chore = Chore.RESTING
	chore_target = null
	chore_time = seconds

func _update_thought() -> void:
	var text: String = ""
	if manual_time <= 0.0 and not catching_up:
		match chore:
			Chore.STRETCHING:
				text = "Aaaah... (bocejo)"
			Chore.WALKING:
				text = "Lá vou eu... devagarinho"
			Chore.PICKING:
				text = "Hmmm... peguei"
			Chore.RESTING:
				# Procrastinating next to the mess is part of the joke.
				if is_instance_valid(collector) and not collector.objects.is_empty():
					text = "Zzz..."
	thought.text = text
	thought.visible = not text.is_empty()
