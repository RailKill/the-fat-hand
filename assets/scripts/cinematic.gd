extends AnimationPlayer
# Plays a cinematic before starting the game.


# Path to countdown timer.
export(NodePath) var countdown_path
# Path to player to take away control from.
export(NodePath) var player_path
# Plays player pain animation if true.
export(bool) var play_pain = false

onready var player = get_node(player_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	connect("animation_finished", self, "done")
	
	$Cinemacam.current = true
	player.is_controllable = false
	play("Begin")
	
	# TODO: Terrible coding, had to rush. Generalize this in future.
	if play_pain:
		player.animation_tree["parameters/PainOneShot/active"] = true
		player.toggle_pain_eyes(true)


func done(_name):
	# Start countdown timer and make player controllable.
	get_node(countdown_path).start()
	player.is_controllable = true
	player.toggle_pain_eyes(false)
	queue_free()
