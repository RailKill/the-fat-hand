extends Node
# Global game configuration.


var is_fullscreen = false
# Number of pizzas to generate in main menu.
var number_of_wins = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func adjust_volume(bus_index: int, value: float):
	AudioServer.set_bus_mute(bus_index, value == 0)
	AudioServer.set_bus_volume_db(bus_index, value / 2 - 50)
