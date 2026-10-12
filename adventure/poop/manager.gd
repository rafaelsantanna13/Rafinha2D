extends Node2D

signal picked_up(total: int)
const Poop = preload("res://adventure/poop/collectible.gd")
const COLLECT_RADIUS: float = 82.0
@export var interval_seconds: float = 27.0
@export var first_delay: float = 8.0
@export var max_objects: int = 12

var followers: Node2D
var sloth: CharacterBody2D
var enabled: bool = true
var elapsed: float = 0.0
var due_times: Array[float] = []
var objects: Array[Node2D] = []
var generated: int = 0

func _physics_process(delta: float) -> void:
	if not enabled or not is_instance_valid(followers):
		return
	elapsed += delta
	while due_times.size() < followers.dogs.size():
		due_times.append(elapsed + first_delay + float(due_times.size() % 4) * 2.0)
	for i in range(due_times.size()):
		if elapsed >= due_times[i]:
			if try_generate(followers.dogs[i]):
				due_times[i] = elapsed + maxf(5.0, interval_seconds) + float(i % 4) * 2.0
			else:
				# Retry later instead of generating every frame on unsuitable terrain.
				due_times[i] = elapsed + 3.0
	for item in objects:
		item.prompt.visible = is_instance_valid(sloth) and can_collect(sloth, item)

func safe_ground(point: Vector2) -> Variant:
	var query = PhysicsRayQueryParameters2D.create(point - Vector2(0, 8), point + Vector2(0, 24), 1)
	var hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	if hit.is_empty() or hit["normal"].y > -0.8:
		return null
	var floor_point: Vector2 = hit["position"]
	# Only a dog standing on a nearby floor can produce an object.
	if absf(floor_point.y - point.y) > 17.0:
		return null
	var space = PhysicsPointQueryParameters2D.new()
	space.position = floor_point - Vector2(0, 18)
	space.collision_mask = 1
	if not get_world_2d().direct_space_state.intersect_point(space).is_empty():
		return null
	return floor_point

func try_generate(dog: Node2D) -> bool:
	if not enabled or objects.size() >= max_objects or not is_instance_valid(dog):
		return false
	var floor_point = safe_ground(dog.global_position + Vector2(12, 0))
	if floor_point == null:
		return false
	for item in objects:
		if item.global_position.distance_to(floor_point) < 68.0:
			return false
	var item = Poop.new()
	item.position = to_local(floor_point)
	add_child(item)
	objects.append(item)
	generated += 1
	dog.poop_time = 0.65
	return true

func can_collect(actor: CharacterBody2D, item: Node2D) -> bool:
	return enabled and actor.actor_name == "Bicho-preguiça" and not item.collected and actor.global_position.distance_to(item.global_position) <= COLLECT_RADIUS and absf(actor.global_position.y - item.global_position.y) <= 35.0

func collect_near(actor: CharacterBody2D) -> bool:
	var closest: Node2D
	var distance: float = INF
	for item in objects:
		if can_collect(actor, item) and actor.global_position.distance_to(item.global_position) < distance:
			closest = item
			distance = actor.global_position.distance_to(item.global_position)
	if not is_instance_valid(closest) or not closest.collect():
		return false
	objects.erase(closest)
	AdventureState.poop_collected += 1
	AdventureState.save_progress()
	picked_up.emit(AdventureState.poop_collected)
	return true

func stop_and_clear() -> void:
	enabled = false
	for item in objects:
		item.queue_free()
	objects.clear()
