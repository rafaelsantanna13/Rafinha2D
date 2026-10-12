extends Control

# Menu independente da fase: mantém a cena MundoRafinha intacta.
const GAME_SCENE: String = "res://mundo_rafinha.tscn"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_menu()

func _build_menu() -> void:
	var background := ColorRect.new()
	background.color = Color("#37dce4")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(450, 400)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#fff8df")
	style.border_color = Color("#19313d")
	style.set_border_width_all(4)
	style.set_corner_radius_all(18)
	style.set_content_margin_all(26)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	panel.add_child(layout)

	var title := Label.new()
	title.text = "RAFINHA2D"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color("#163241"))
	layout.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "A aventura vai começar!"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", Color("#31495b"))
	layout.add_child(subtitle)

	var play := Button.new()
	play.text = "JOGAR"
	play.custom_minimum_size = Vector2(280, 66)
	play.add_theme_font_size_override("font_size", 30)
	play.pressed.connect(_start_game)
	layout.add_child(play)

	var heading := Label.new()
	heading.text = "CONTROLES DO TECLADO"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 20)
	heading.add_theme_color_override("font_color", Color("#163241"))
	layout.add_child(heading)

	_add_controls(layout, "BIGO", "A / D: andar    V: pular    E: pum!")
	_add_controls(layout, "MARINA", "1 / 3: andar    L: pular")

	var hint := Label.new()
	hint.text = "Clique em JOGAR para começar"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 15)
	hint.add_theme_color_override("font_color", Color("#53636b"))
	layout.add_child(hint)

	play.grab_focus()

func _add_controls(parent: VBoxContainer, name: String, keys: String) -> void:
	var heading := Label.new()
	heading.text = name
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 19)
	heading.add_theme_color_override("font_color", Color("#163241"))
	parent.add_child(heading)
	var info := Label.new()
	info.text = keys
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 17)
	info.add_theme_color_override("font_color", Color("#31495b"))
	parent.add_child(info)

func _start_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
