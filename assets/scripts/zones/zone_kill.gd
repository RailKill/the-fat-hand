class_name ZoneKill
extends Area


# Quits the game if body is killed.
export(bool) var quit = false


func _ready():
	# warning-ignore:return_value_discarded
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body):
	if body.has_method("die"):
		body.die(!quit)
		if quit:
			get_parent().exit(1.0)
