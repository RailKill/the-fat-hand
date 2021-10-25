class_name GlobalConfiguration
extends Node
# Global game configuration.


# Bit value of the environment collision layer.
const ENVIRONMENT_LAYER = 1
# Bit value of the character collision layer.
const CHARACTER_LAYER = 2
# Bit value of the grabbable collision layer.
const GRABBABLE_LAYER = 4
# Bit value of the boundary collision layer.
const BOUNDARY_LAYER = 8

# Checks if the game is set to fullscreen option.
var is_fullscreen = false
# Number of pizzas to generate in main menu.
var number_of_wins = 0
# Cinematics played.
var cinematic_played = {1: false, 2: false}

# Global music player.
onready var music_player = $AudioStreamPlayer


func _input(event):
	if event.is_action_pressed("ui_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen


func play(number):
	cinematic_played[number] = true


# Reset cinematics when game is started from main menu.
func reset_cinematics():
	cinematic_played = {1: false, 2: false}
