extends Node2D

signal performed(kind: String, hits: int)
const Pulse = preload("res://adventure/combat/pulse.gd")
var villains: Array[CharacterBody2D] = []
var judo_hits: int = 0
var force_hits: int = 0

func use(actor: CharacterBody2D, kind: String) -> int:
	if (kind == "judo" and actor.actor_name != "Rafinha") or (kind == "force" and actor.actor_name != "Guilherme") or kind not in ["judo", "force"]:
		return 0
	var radius: float = 130.0 if kind == "judo" else 320.0
	var hits: int = 0
	var pulse_direction: float = actor.face
	for villain in villains:
		var offset: Vector2 = villain.global_position - actor.global_position
		if not villain.defeated and offset.length() <= radius and absf(offset.y) <= 110.0:
			if villain.react(kind, signf(offset.x) if absf(offset.x) > 1.0 else actor.face):
				hits += 1
	var effect = Pulse.new()
	effect.kind = kind
	effect.direction = pulse_direction
	if hits > 0:
		actor.face = pulse_direction
	effect.position = actor.hand_position()
	effect.z_index = 5
	add_child(effect)
	judo_hits += hits if kind == "judo" else 0
	force_hits += hits if kind == "force" else 0
	performed.emit(kind, hits)
	return hits
