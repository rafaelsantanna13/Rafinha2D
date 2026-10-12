class_name AdventureUI
extends RefCounted

static func label(text: String, size: int = 24) -> Label:
	var item = Label.new()
	item.text = text
	item.add_theme_font_size_override("font_size", size)
	item.add_theme_color_override("font_color", Color("#243449"))
	return item

static func style(color: String = "#fff6dc", border: int = 3) -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = Color(color)
	box.border_color = Color("#3b3443")
	box.set_border_width_all(border)
	box.set_corner_radius_all(18)
	box.set_content_margin_all(15)
	return box

static func panel() -> PanelContainer:
	var item = PanelContainer.new()
	item.add_theme_stylebox_override("panel", style())
	return item

static func button(text: String, callback: Callable, primary: bool = false) -> Button:
	var item = Button.new()
	item.text = text
	item.custom_minimum_size = Vector2(0, 48)
	item.add_theme_font_size_override("font_size", 23)
	item.add_theme_color_override("font_color", Color("#243449"))
	item.add_theme_stylebox_override("normal", style("#ffd371" if primary else "#e6f3f4"))
	item.add_theme_stylebox_override("hover", style("#ffb960" if primary else "#c7e6ed"))
	item.add_theme_stylebox_override("pressed", style("#ffa052"))
	item.pressed.connect(callback)
	return item
