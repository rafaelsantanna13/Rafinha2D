extends Control

const UI = preload("res://adventure/ui.gd")
const Catalog = preload("res://adventure/catalog.gd")

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background = ColorRect.new()
	background.color = Color("#acdfe8")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var castle = TextureRect.new()
	castle.texture = preload("res://adventure/art/castle_3.svg")
	castle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	castle.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	castle.modulate = Color(1, 1, 1, 0.45)
	add_child(castle)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel = UI.panel()
	panel.custom_minimum_size = Vector2(820, 0)
	center.add_child(panel)
	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	panel.add_child(layout)
	var title = UI.label("VIVA! TODOS JUNTOS!", 44)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)
	var message = UI.label("Bigo, Rafinha e Marina chegaram com os cachorros!", 25)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(message)
	var lineup = HBoxContainer.new()
	lineup.alignment = BoxContainer.ALIGNMENT_CENTER
	lineup.add_theme_constant_override("separation", 20)
	layout.add_child(lineup)
	for path in ["res://1760301079346.svg", "res://Bigo2.svg", "res://Marina.svg"]:
		_portrait(lineup, path, Vector2(110, 165))
	for id in AdventureState.rescued_dogs:
		_portrait(lineup, "res://adventure/art/" + Catalog.DOGS[id]["art"] + "_rescue.svg", Vector2(115, 125))
	var names: PackedStringArray = []
	for id in AdventureState.rescued_dogs:
		names.append(Catalog.DOGS[id]["name"])
	var dogs = UI.label("Cachorros resgatados: " + ", ".join(names), 23)
	dogs.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(dogs)
	layout.add_child(UI.button("VOLTAR AO MENU", func(): get_tree().change_scene_to_file("res://menu_inicial.tscn"), true))
	var note = UI.label("Fim da demonstração. Rafaela pode escolher os próximos castelos!", 19)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(note)
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.rafinhaAdventure = {finished:true}", true)
	print("ADVENTURE_CELEBRATION_READY")

func _portrait(parent: HBoxContainer, path: String, dimensions: Vector2) -> void:
	var image = TextureRect.new()
	image.texture = UI.cropped_texture(load(path))
	image.custom_minimum_size = dimensions
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	parent.add_child(image)
