class_name CastleCatalog
extends RefCounted

# Três castelos de demonstração. Nomes e aparência do amigo aguardam a Rafaela.
const DOGS = {
	"fofins": {"name": "Fófins", "art": "fofins", "collar": Color("#ef5685")},
	"amigo_provisorio": {"name": "Amigo (provisório)", "art": "amigo", "collar": Color("#24a6bc")},
}
const LEVELS = [
	{"title": "O Castelo da Fófins", "scene": "res://adventure/levels/castle_1.tscn",
	 "dog": "fofins", "sky": Color("#93dfe9"), "stone": Color("#eed29b"),
	 "roof": Color("#f179a4"), "hint": "Vamos até a Fófins! Chegue pertinho para resgatar.",
	 "steps": [Vector4(390, 570, 230, 55), Vector4(615, 515, 240, 28), Vector4(845, 460, 250, 28), Vector4(1065, 405, 250, 28)]},
	{"title": "O Castelo dos Amigos", "scene": "res://adventure/levels/castle_2.tscn",
	 "dog": "amigo_provisorio", "sky": Color("#b8e6ce"), "stone": Color("#bbd5dd"),
	 "roof": Color("#8863b5"), "hint": "Fófins veio junto! Vamos buscar mais um amigo.",
	 "steps": [Vector4(410, 570, 205, 55), Vector4(610, 515, 205, 28), Vector4(810, 460, 205, 28), Vector4(1010, 405, 240, 28)]},
	{"title": "O Castelo Final (provisório)", "scene": "res://adventure/levels/castle_3.tscn",
	 "dog": "", "sky": Color("#cdd5f6"), "stone": Color("#e8c3e5"),
	 "roof": Color("#526ec8"), "hint": "Com os cachorros, pegue as 3 patinhas e encontre a festa!",
	 "steps": [Vector4(410, 570, 220, 55), Vector4(625, 515, 220, 28), Vector4(840, 460, 220, 28), Vector4(1055, 405, 240, 28)]},
]

static func scene_for(index: int) -> String:
	return LEVELS[clampi(index, 0, LEVELS.size() - 1)]["scene"]
