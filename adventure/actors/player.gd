extends CharacterBody2D

signal took_control(actor)

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0
const PUM = preload("res://pum_bigo.tscn")
const UI = preload("res://adventure/ui.gd")

@export var actor_name: String = "Rafinha"
@export var left_action: String = "ui_left"
@export var right_action: String = "ui_right"
@export var jump_action: String = "ui_accept"
@export var art: Texture2D
@export var art_height: float = 132.0

var face: float = 1.0
var automatic_target: Vector2 = Vector2.ZERO
var automatic_follow: bool = false
var world_width: float = 2500.0
var walk_time: float = 0.0
var manual_time: float = 0.0
var coyote_time: float = 0.0
var jump_buffer: float = 0.0
var pum_cooldown: float = 0.0
var spawn_point: Vector2
var sprite: Sprite2D
var pum: Node2D

func _ready() -> void:
	add_to_group("adventure_players")
	spawn_point = global_position
	sprite = $Sprite2D
	sprite.texture = UI.cropped_texture(art)
	if art:
		var factor: float = art_height / sprite.texture.get_height()
		sprite.scale = Vector2(factor, factor)
		sprite.position.y = -art_height * 0.5
	$Name.text = actor_name
	if actor_name == "Bigo":
		add_to_group("Bigo")
		pum = PUM.instantiate()
		pum.scale = Vector2(0.16, 0.16)
		pum.position = Vector2(-28, -38)
		add_child(pum)
		pum.get_node("AnimationPlayer").play("RESET")

func _physics_process(delta: float) -> void:
	manual_time = maxf(0.0, manual_time - delta)
	pum_cooldown = maxf(0.0, pum_cooldown - delta)
	var direction: float = Input.get_axis(left_action, right_action)
	var jumping: bool = Input.is_action_just_pressed(jump_action)
	if not is_zero_approx(direction) or jumping:
		manual_time = 0.7
		took_control.emit(self)
	if actor_name == "Bigo" and Input.is_action_just_pressed("Tecla_bigopum") and pum_cooldown <= 0.0:
		pum.get_node("AnimationPlayer").play("aparecer_sumir")
		pum_cooldown = 0.5
	if is_on_floor():
		coyote_time = 0.12
	else:
		coyote_time = maxf(0.0, coyote_time - delta)
		velocity += get_gravity() * delta
	jump_buffer = 0.12 if jumping else maxf(0.0, jump_buffer - delta)
	if automatic_follow and manual_time <= 0.0:
		var separation: float = automatic_target.x - global_position.x
		if absf(separation) > 25.0:
			direction = signf(separation)
			if is_on_floor() and (is_on_wall() or automatic_target.y < global_position.y - 30.0):
				jump_buffer = 0.12
	if jump_buffer > 0.0 and coyote_time > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buffer = 0.0
		coyote_time = 0.0
	if direction:
		velocity.x = direction * SPEED
		face = direction
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
	move_and_slide()
	global_position.x = clampf(global_position.x, 28.0, world_width - 28.0)
	if global_position.y > 820.0:
		global_position = spawn_point
		velocity = Vector2.ZERO
	walk_time += delta * absf(velocity.x) * 0.04
	sprite.rotation = sin(walk_time) * 0.025 if absf(velocity.x) > 10.0 else lerpf(sprite.rotation, 0.0, delta * 10.0)
	sprite.flip_h = face < 0.0

func hand_position() -> Vector2:
	return global_position + Vector2(face * 24.0, -75.0)
