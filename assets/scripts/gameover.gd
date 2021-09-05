extends Control
# Handles scene changes when the game is over.


# Resource path of the next level's scene.
export(String) var next_level


# Return to main menu.
func exit():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://assets/scenes/00_menu.tscn")


# Proceeds to next level if there is one, else exit.
func next():
	if not next_level or get_tree().change_scene(next_level) != OK:
		exit()


# Reloads current scene.
func retry():
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
