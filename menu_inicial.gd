extends Control

const UI = preload("res://adventure/ui.gd")
const Catalog = preload("res://adventure/catalog.gd")
const GAME_SCENE: String = "res://mundo_rafinha.tscn"
var reset_confirmation: ConfirmationDialog

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_menu()
	if OS.has_feature("web"):
		call_deferred("_web_menu_probe")
	print("ADVENTURE_MENU_READY")

func _build_menu() -> void:
	var background = ColorRect.new()
	background.color = Color("#93dfe9")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var castle = TextureRect.new()
	castle.texture = preload("res://adventure/art/castle_1.svg")
	castle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	castle.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	castle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(castle)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel = UI.panel()
	panel.custom_minimum_size = Vector2(900, 0)
	center.add_child(panel)
	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 5)
	panel.add_child(layout)
	var title = UI.label("RAFINHA2D", 44)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(title)
	var subtitle = UI.label("A AVENTURA DOS CASTELOS", 26)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(subtitle)
	var lineup = HBoxContainer.new()
	lineup.alignment = BoxContainer.ALIGNMENT_CENTER
	lineup.add_theme_constant_override("separation", 18)
	layout.add_child(lineup)
	for path in ["res://1760301079346.svg", "res://Bigo2.svg", "res://Marina.svg", "res://adventure/art/fofins_idle.svg", "res://adventure/art/tokio_idle.svg", "res://adventure/art/sloth_idle.svg", "res://adventure/art/guilherme_idle.svg", "res://adventure/art/snoopy_idle.svg"]:
		var portrait = TextureRect.new()
		portrait.texture = UI.cropped_texture(load(path))
		portrait.custom_minimum_size = Vector2(72, 70)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		lineup.add_child(portrait)
	var play = UI.button("JOGAR", _start_game, true)
	play.custom_minimum_size.y = 56
	var actions = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	layout.add_child(actions)
	play.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(play)
	if AdventureState.has_save:
		var caption: String = "VER A FESTA" if AdventureState.finished else "CONTINUAR - CASTELO " + str(AdventureState.current_level + 1)
		var continue_button = UI.button(caption, _continue_game)
		continue_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		actions.add_child(continue_button)
	var guide = UI.label("Rafinha: setas esquerda/direita | Espaço: pular | F: judô\nBigo: A / D: andar | V: pular | E: pum\nMarina: 1 / 3: andar | L: pular\nPreguiça: J / K: andar | U: pular | I: recolher cocô\nGuilherme Jedi: Z / X: andar | B: pular | Q: Força", 21)
	guide.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(guide)
	var hint = UI.label("Chegue pertinho dos cachorros para resgatar.\nRafinha conduz as guias. A preguiça vem se ficar para trás.", 20)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(hint)
	var assist = CheckBox.new()
	assist.text = "Ajuda para Rafinha, Bigo, Marina e Guilherme na caminhada"
	assist.button_pressed = AdventureState.assist_friends
	assist.add_theme_color_override("font_color", Color("#243449"))
	for state in ["font_focus_color", "font_hover_color", "font_pressed_color", "font_hover_pressed_color"]:
		assist.add_theme_color_override(state, Color("#243449"))
	assist.add_theme_font_size_override("font_size", 19)
	assist.toggled.connect(func(enabled: bool): AdventureState.assist_friends = enabled)
	layout.add_child(assist)
	layout.add_child(UI.button("JOGO ORIGINAL", func(): get_tree().change_scene_to_file(GAME_SCENE)))
	var note = UI.label("5 castelos, resgates e uma turma pronta para a aventura!", 17)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(note)
	var saving = UI.label(AdventureState.save_notice if not AdventureState.save_notice.is_empty() else "Progresso guardado só neste navegador e neste computador.", 17)
	saving.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(saving)
	reset_confirmation = ConfirmationDialog.new()
	reset_confirmation.title = "Reiniciar a aventura?"
	reset_confirmation.dialog_text = "Os resgates salvos serão apagados para começar do Castelo da Fófins."
	reset_confirmation.ok_button_text = "COMEÇAR DE NOVO"
	reset_confirmation.cancel_button_text = "VOLTAR"
	reset_confirmation.confirmed.connect(_new_game)
	add_child(reset_confirmation)
	play.grab_focus()

func _start_game() -> void:
	if AdventureState.has_save:
		reset_confirmation.popup_centered(Vector2i(650, 160))
	else:
		_new_game()

func _new_game() -> void:
	AdventureState.new_adventure()
	get_tree().change_scene_to_file(Catalog.scene_for(0))

func _continue_game() -> void:
	var scene: String = "res://adventure/celebration.tscn" if AdventureState.finished else Catalog.scene_for(AdventureState.current_level)
	get_tree().change_scene_to_file(scene)

func _web_menu_probe() -> void:
	await get_tree().process_frame
	var buttons: Array = []
	for item in find_children("*", "Button", true, false):
		var rect: Rect2 = item.get_global_rect()
		buttons.append({"text": item.text, "x": rect.position.x, "y": rect.position.y, "w": rect.size.x, "h": rect.size.y})
	var value: String = JSON.stringify({"menu": true, "release": Catalog.CONTENT_VERSION, "has_save": AdventureState.has_save, "buttons": buttons})
	JavaScriptBridge.eval("window.rafinhaAdventure = " + value, true)
