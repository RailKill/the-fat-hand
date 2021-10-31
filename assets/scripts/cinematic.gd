extends AnimationPlayer
# Plays a cinematic before starting the game.


# Path to countdown timer.
export(NodePath) var countdown_path
# Path to player to take away control from.
export(NodePath) var player_path
# Plays player pain animation if true.
export(bool) var play_pain = false
# The number of this level. Used for cinematic tracking per level.
export(int) var level_number

onready var player = get_node(player_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	if not Global.cinematic_played[level_number]:
		# warning-ignore:return_value_discarded
		connect("animation_finished", self, "done")
		
		$Cinemacam.current = true
		player.disable()
		play("Begin")
		Global.play(level_number)
		
		# TODO: Terrible coding, had to rush. Generalize this in future.
		if play_pain:
			player.animation_tree["parameters/PainEmote/active"] = true
			player.toggle_pain_eyes(true)
	else:
		done("Begin")


func done(_name):
	# Start countdown timer and make player controllable.
	get_node(countdown_path).start()
	player.enable()
	player.toggle_pain_eyes(false)
	queue_free()
