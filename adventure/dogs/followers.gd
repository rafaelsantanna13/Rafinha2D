extends Node2D

const Catalog = preload("res://adventure/catalog.gd")
const Visual = preload("res://adventure/dogs/dog_visual.gd")
const SPACING: float = 112.0

var leader: CharacterBody2D
var dogs: Array[Node2D] = []
var trail: Array[Vector2] = []
var velocities: Array[Vector2] = []
var dog_ids: Array[String] = []
var celebrate_times: Array[float] = []

func set_leader(actor: CharacterBody2D) -> void:
	if leader == actor:
		return
	leader = actor
	reset_trail()

func reset_trail() -> void:
	trail.clear()
	if not is_instance_valid(leader):
		return
	# Seed a spaced, floor-level formation after changing scenes or a recovery.
	for i in range(100):
		var point: Vector2 = leader.global_position - Vector2(leader.face * i * 5.0, 0.0)
		if i > 0 and is_inside_tree():
			var query = PhysicsRayQueryParameters2D.create(point - Vector2(0, 5), point + Vector2(0, 400), 1)
			var floor_hit: Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
			if not floor_hit.is_empty():
				point.y = floor_hit["position"].y
		trail.append(point)
	for i in range(dogs.size()):
		dogs[i].global_position = target_at(SPACING * (i + 1))
		velocities[i] = Vector2.ZERO

func add_dog(id: String, just_rescued: bool = false) -> void:
	if id in dog_ids:
		return
	var dog = Visual.new()
	dog.art_id = Catalog.DOGS[id]["art"]
	add_child(dog)
	dogs.append(dog)
	dog_ids.append(id)
	velocities.append(Vector2.ZERO)
	celebrate_times.append(0.7 if just_rescued else 0.0)
	dog.global_position = target_at(SPACING * dogs.size())

func target_at(distance: float) -> Vector2:
	if trail.is_empty():
		return leader.global_position if is_instance_valid(leader) else Vector2.ZERO
	var remaining: float = distance
	for i in range(1, trail.size()):
		var segment: float = trail[i - 1].distance_to(trail[i])
		if segment >= remaining and segment > 0.001:
			return trail[i - 1].lerp(trail[i], remaining / segment)
		remaining -= segment
	return trail.back()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(leader):
		return
	if trail.is_empty() or trail[0].distance_to(leader.global_position) > 500.0:
		reset_trail()
	elif trail[0].distance_to(leader.global_position) >= 3.0:
		trail.push_front(leader.global_position)
		# Keep enough history for all dogs instead of a fixed two-dog limit.
		if trail.size() > maxi(600, dogs.size() * 60):
			trail.pop_back()
	for i in range(dogs.size()):
		var target: Vector2 = target_at(SPACING * (i + 1))
		var difference: Vector2 = target - dogs[i].global_position
		var desired: Vector2 = (difference * 7.0).limit_length(470.0)
		velocities[i] = velocities[i].move_toward(desired, 2200.0 * delta)
		if difference.length() < 1.0 and velocities[i].length() < 9.0:
			velocities[i] = Vector2.ZERO
		else:
			dogs[i].global_position += velocities[i] * delta
		if absf(velocities[i].x) > 8.0:
			dogs[i].facing = signf(velocities[i].x)
		celebrate_times[i] = maxf(0.0, celebrate_times[i] - delta)
		dogs[i].animate(delta, velocities[i].length() > 10.0, celebrate_times[i] > 0.0)
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(leader):
		return
	var hand: Vector2 = to_local(leader.hand_position())
	for i in range(dogs.size()):
		var collar: Vector2 = to_local(dogs[i].collar_position())
		var curve = Curve2D.new()
		var slack: float = minf(35.0, hand.distance_to(collar) * 0.15)
		curve.add_point(hand, Vector2.ZERO, Vector2(0, slack))
		curve.add_point(collar, Vector2(0, slack), Vector2.ZERO)
		var points: PackedVector2Array = curve.get_baked_points()
		draw_polyline(points, Color("#443531"), 5.0, true)
		draw_polyline(points, Catalog.DOGS[dog_ids[i]]["collar"], 2.8, true)
		draw_circle(collar, 4.0, Color("#ffd66c"))
