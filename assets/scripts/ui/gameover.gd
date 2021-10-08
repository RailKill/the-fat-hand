class_name GameOver
extends Control
# Handles scene changes when the game is over.


# Resource path of the next level's scene.
export(String) var next_level


# Return to main menu.
func exit():
	# If already in main menu, and is not on web, then quit the game.
	if get_tree().current_scene.name == "LevelMenu" and \
			not OS.has_feature("web"):
		get_tree().quit()
	else:
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://assets/scenes/levels/00_menu.tscn")
		get_node("/root/Global").reset_cinematics()


# Proceeds to next level if there is one, else exit.
func next():
	if not next_level or get_tree().change_scene(next_level) != OK:
		exit()


# Reloads current scene.
func retry():
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
