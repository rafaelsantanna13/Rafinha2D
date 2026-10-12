extends Node2D

var kind: String = "force"
var direction: float = 1.0
var time: float = 0.0

func _process(delta: float) -> void:
	time += delta
	queue_redraw()
	if time > 0.55:
		queue_free()

func _draw() -> void:
	var progress: float = time / 0.55
	var color = Color("#76e6ed") if kind == "force" else Color("#df87ef")
	color.a = 1.0 - progress
	for i in range(3):
		var radius: float = 25.0 + progress * (160.0 if kind == "force" else 75.0) + i * 12.0
		var angle: float = 0.0 if direction > 0 else PI
		draw_arc(Vector2.ZERO, radius, angle - 0.85, angle + 0.85, 24, color, 4.0, true)
	if kind == "judo":
		for i in range(5):
			var angle: float = i * TAU / 5.0 + time * 3.0
			var point = Vector2(cos(angle), sin(angle)) * (25 + progress * 65)
			draw_line(point - Vector2(6, 0), point + Vector2(6, 0), color, 3)
			draw_line(point - Vector2(0, 6), point + Vector2(0, 6), color, 3)
