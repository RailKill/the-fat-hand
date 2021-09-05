extends Control


# Return to main menu.
func exit():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://assets/scenes/00_menu.tscn")


# Reloads current scene.
func retry():
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
