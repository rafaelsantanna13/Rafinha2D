extends Node

# Music and effects are synthesized by scripts/generate_audio.py. They are
# loaded at runtime: an autoload preload would be parsed before the first
# editor import of a clean checkout.
const FOLDER = "res://adventure/audio/"
const SOUND_NAMES = ["jump", "rescue", "collect", "paw", "judo", "force", "pum", "gate", "yawn"]
const VOLUME = {"jump": -14.0, "pum": -4.0, "yawn": -5.0}
const MUSIC_DB: float = -11.0
const VOICES: int = 8

var music: AudioStreamPlayer
var voices: Array[AudioStreamPlayer] = []
var played: Dictionary = {}
var sounds: Dictionary = {}
# The headless Dummy driver never mixes, so its playbacks would never be
# released; there nothing is started, but requests are still counted.
var audible: bool = AudioServer.get_driver_name() != "Dummy"

func _ready() -> void:
	# Music keeps playing under the Help pause and across scene changes.
	process_mode = Node.PROCESS_MODE_ALWAYS
	music = AudioStreamPlayer.new()
	music.stream = load(FOLDER + "music_castle.wav")
	for sound in SOUND_NAMES:
		sounds[sound] = load(FOLDER + sound + ".wav")
	music.volume_db = MUSIC_DB
	add_child(music)
	for i in range(VOICES):
		var voice = AudioStreamPlayer.new()
		add_child(voice)
		voices.append(voice)
	apply_setting()

func apply_setting() -> void:
	if AdventureState.sound_on and audible and not music.playing:
		music.play()
	elif not AdventureState.sound_on:
		music.stop()
		for voice in voices:
			voice.stop()

func toggle() -> bool:
	AdventureState.sound_on = not AdventureState.sound_on
	AdventureState.save_progress()
	apply_setting()
	return AdventureState.sound_on

func play(sound: String, pitch: float = 1.0) -> void:
	played[sound] = int(played.get(sound, 0)) + 1
	if not AdventureState.sound_on or not audible or not sounds.has(sound):
		return
	var chosen: AudioStreamPlayer = voices[0]
	for voice in voices:
		if not voice.playing:
			chosen = voice
			break
	chosen.stream = sounds[sound]
	chosen.volume_db = VOLUME.get(sound, -6.0)
	chosen.pitch_scale = pitch
	chosen.play()

func music_active() -> bool:
	return AdventureState.sound_on and (music.playing or not audible)
