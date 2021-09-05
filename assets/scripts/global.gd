extends Node
# Global game configuration.


var is_fullscreen = false
# Number of pizzas to generate in main menu.
var number_of_wins = 0
# Cinematics played.
var cinematic_played = {1: false, 2: false}

onready var music_player = $AudioStreamPlayer


func play(number):
	cinematic_played[number] = true


# Reset cinematics when game is started from main menu.
func reset_cinematics():
	cinematic_played = {1: false, 2: false}
