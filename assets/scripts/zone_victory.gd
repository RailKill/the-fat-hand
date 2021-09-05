extends Area


# Path to the countdown's node so that it could be stopped upon victory.
export(NodePath) var countdown_path
# The path to the next level's scene. Can be left empty if it should return to
# the main menu.
export(String) var next_scene

# Victory screen interface.
var ui = preload("res://assets/ui/victory.tscn")

# The countdown node.
onready var countdown = get_node(countdown_path)


func _ready():
	var _error = connect("body_entered", self, "_on_body_entered")


# If Player enters this zone, create and show victory interface.
func _on_body_entered(body):
	if body is Player:
		body.disable()
		countdown.stop()
		var instance = ui.instance()
		instance.next_level = next_scene
		add_child(instance)
