extends Node
# Global game configuration.


signal option_changed(section, key, value)


# File path to store game settings.
const OPTIONS_FILE = "user://options.cfg"

# Bit value of the environment collision layer.
const ENVIRONMENT_LAYER = 1
# Bit value of the character collision layer.
const CHARACTER_LAYER = 2
# Bit value of the grabbable collision layer.
const GRABBABLE_LAYER = 4
# Bit value of the boundary collision layer.
const BOUNDARY_LAYER = 8
# Dictionary of audio bus names and their indices.
const BUS_DICTIONARY = {
	0: "master",
	1: "music",
	2: "sfx",
}

# Checks if the game is set to fullscreen option.
var is_fullscreen = false
# Number of pizzas to generate in main menu.
var number_of_wins = 0
# Game settings.
var options = ConfigFile.new()
# Cinematics played.
var cinematic_played = {1: false, 2: false}

# Global music player.
onready var music_player = $AudioStreamPlayer


func _ready():
	# Load options.
	var error = options.load(OPTIONS_FILE)
	if error != OK:
		set_option("display", "fullscreen", 0)
		for bus in BUS_DICTIONARY.values():
			set_option("sound", "%s_volume" % bus, 50)
	apply_options()


func _input(event):
	if event.is_action_pressed("ui_fullscreen"):
		var toggle = !OS.window_fullscreen
		var state = int(toggle)
		OS.window_fullscreen = toggle
		set_option("display", "fullscreen", state)


# Apply changes to game settings.
func apply_options():
	var fullscreen = bool(options.get_value("display", "fullscreen"))
	if OS.window_fullscreen != fullscreen:
		OS.window_fullscreen = fullscreen


# Records the playing of cinematics for the given level number.
func play(number):
	cinematic_played[number] = true


# Reset cinematics when game is started from main menu.
func reset_cinematics():
	cinematic_played = {1: false, 2: false}


# Save an option into the options file. Emits a signal if broadcast is true.
func set_option(section, key, value, broadcast = true):
	options.set_value(section, key, value)
	options.save(OPTIONS_FILE)
	apply_options()
	if broadcast:
		emit_signal("option_changed", section, key, value)
