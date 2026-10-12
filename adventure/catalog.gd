class_name CastleCatalog
extends RefCounted

# Os oito amigos novos têm identidades provisórias, para a Rafaela escolher.
const CONTENT_VERSION = "jedi-judo-snoopy-1"
const DOGS = {
	"snoopy": {"name": "Snoopy", "art": "snoopy", "collar": Color("#db5357")},
	"fofins": {"name": "Fófins", "art": "fofins", "collar": Color("#ef5685"), "female": true},
	"tokio": {"name": "Tokio", "art": "tokio", "collar": Color("#24a6bc"), "female": true},
	"amigo_creme": {"name": "Amigo Creme", "art": "creme", "collar": Color("#dc5692")},
	"amigo_cinza": {"name": "Amigo Cinza", "art": "cinza", "collar": Color("#ef8d2d")},
	"amigo_caramelo": {"name": "Amigo Caramelo", "art": "caramelo", "collar": Color("#586be0")},
	"amigo_malhado": {"name": "Amigo Malhado", "art": "malhado", "collar": Color("#28a878")},
	"amigo_dourado": {"name": "Amigo Dourado", "art": "dourado", "collar": Color("#df6480")},
	"amigo_chocolate": {"name": "Amigo Chocolate", "art": "chocolate", "collar": Color("#3bafce")},
	"amigo_branco": {"name": "Amigo Branco", "art": "branco", "collar": Color("#9a61d6")},
	"amigo_pintinhas": {"name": "Amigo Pintinhas", "art": "pintinhas", "collar": Color("#ed7844")},
}
const LEVELS = [
	{"title": "O Castelo da Fófins", "scene": "res://adventure/levels/castle_1.tscn", "width": 2500.0,
	 "rescues": {"fofins": Vector2(1190, 405)}, "sky": Color("#93dfe9"), "stone": Color("#eed29b"),
	 "roof": Color("#f179a4"), "hint": "Vamos até a Fófins! Chegue pertinho para resgatar.",
	 "steps": [Vector4(390, 570, 230, 55), Vector4(615, 515, 240, 28), Vector4(845, 460, 250, 28), Vector4(1065, 405, 250, 28), Vector4(1480, 570, 175, 55), Vector4(1745, 570, 170, 55)]},
	{"title": "O Castelo dos Amigos", "scene": "res://adventure/levels/castle_2.tscn", "width": 2500.0,
	 "rescues": {"tokio": Vector2(1135, 405)}, "sky": Color("#b8e6ce"), "stone": Color("#bbd5dd"),
	 "roof": Color("#8863b5"), "hint": "Fófins veio junto! Vamos buscar a Tokio.",
	 "steps": [Vector4(410, 570, 205, 55), Vector4(610, 515, 205, 28), Vector4(810, 460, 205, 28), Vector4(1010, 405, 240, 28), Vector4(1480, 570, 175, 55), Vector4(1745, 570, 170, 55)]},
	{"title": "O Castelo das Patinhas", "scene": "res://adventure/levels/castle_3.tscn", "width": 2500.0,
	 "rescues": {}, "paws": true, "sky": Color("#cdd5f6"), "stone": Color("#e8c3e5"),
	 "roof": Color("#526ec8"), "hint": "Com os cachorros, pegue as 3 patinhas e siga a aventura!",
	 "steps": [Vector4(410, 570, 220, 55), Vector4(625, 515, 220, 28), Vector4(840, 460, 220, 28), Vector4(1055, 405, 240, 28), Vector4(1480, 570, 175, 55), Vector4(1745, 570, 170, 55)]},
	{"title": "O Castelo dos Muitos Cachorros", "scene": "res://adventure/levels/castle_4.tscn", "width": 3200.0,
	 "main_rescue": "snoopy", "house": Vector2(1790, 625),
	 "rescues": {"amigo_creme": Vector2(700, 570), "amigo_cinza": Vector2(1270, 515), "snoopy": Vector2(1810, 460), "amigo_caramelo": Vector2(1960, 570), "amigo_malhado": Vector2(2640, 570)},
	 "sky": Color("#ffdf9f"), "stone": Color("#e9b184"), "roof": Color("#df695b"),
	 "hint": "Snoopy dorme na casinha vermelha! Resgate ele e os quatro amigos.",
	 "steps": [Vector4(570, 570, 245, 55), Vector4(960, 570, 210, 55), Vector4(1155, 515, 245, 28), Vector4(1450, 570, 160, 55), Vector4(1580, 515, 160, 28), Vector4(1750, 460, 140, 18), Vector4(1830, 570, 250, 55), Vector4(2490, 570, 280, 55)]},
	{"title": "O Castelo da Toca Secreta", "scene": "res://adventure/levels/castle_5.tscn", "width": 3500.0, "cave": true,
	 "rescues": {"amigo_dourado": Vector2(700, 570), "amigo_chocolate": Vector2(1770, 850), "amigo_branco": Vector2(2590, 570), "amigo_pintinhas": Vector2(3070, 515)},
	 "sky": Color("#a7dce1"), "stone": Color("#a5c6bf"), "roof": Color("#4095a0"),
	 "hint": "Mais quatro amigos! Explore o caminho e chegue pertinho.",
	 "steps": [Vector4(570, 570, 245, 55), Vector4(1400, 685, 130, 35), Vector4(1490, 740, 140, 35), Vector4(1590, 795, 140, 35), Vector4(1900, 795, 200, 35), Vector4(2020, 740, 180, 35), Vector4(2120, 685, 160, 35), Vector4(2460, 570, 260, 55), Vector4(2790, 570, 205, 55), Vector4(2970, 515, 220, 28)]},
]

static func scene_for(index: int) -> String:
	return LEVELS[clampi(index, 0, LEVELS.size() - 1)]["scene"]

static func required_dogs(index: int) -> Array:
	return LEVELS[index]["rescues"].keys()
