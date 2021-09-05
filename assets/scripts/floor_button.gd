extends Spatial


func _on_pressed(body):
	if body is Player:
		$AnimationPlayer.play("Press")


func _on_animation_complete(_name):
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://assets/scenes/01_toilet.tscn")
