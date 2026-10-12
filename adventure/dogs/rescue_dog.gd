extends Area2D

signal rescued(dog_id: String)

const Catalog = preload("res://adventure/catalog.gd")
const Visual = preload("res://adventure/dogs/dog_visual.gd")
@export var dog_id: String = "fofins"

var dwell: float = 0.0
var is_rescued: bool = false
var celebrating: float = 0.0
var visual: Node2D
var label: Label

func _ready() -> void:
	visual = Visual.new()
	visual.art_id = Catalog.DOGS[dog_id]["art"]
	add_child(visual)
	label = $Label
	label.text = Catalog.DOGS[dog_id]["name"] + "\nChegue pertinho!"

func _physics_process(delta: float) -> void:
	if is_rescued:
		celebrating += delta
		visual.animate(delta, false, true)
		visual.position.y = -sin(minf(celebrating, 0.7) / 0.7 * PI) * 22.0
		if celebrating >= 0.7:
			queue_free()
		return
	var near: bool = false
	for body in get_overlapping_bodies():
		if body.is_in_group("adventure_players") and (not body.automatic_follow or body.manual_time > 0.0):
			near = true
	dwell = dwell + delta if near else 0.0
	visual.animate(delta, false)
	if near:
		label.text = "Oi! Vamos juntos?"
	if dwell >= 0.45:
		rescue()

func rescue() -> bool:
	if is_rescued or not AdventureState.rescue_dog(dog_id):
		return false
	is_rescued = true
	label.text = Catalog.DOGS[dog_id]["name"] + " resgatada!" if dog_id == "fofins" else "Amigo resgatado!"
	rescued.emit(dog_id)
	return true
