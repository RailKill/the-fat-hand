class_name Level
extends Spatial
# Each level in this game should have this script attached.


# The music that will play when this level loads.
export(AudioStream) var level_music


func _ready():
	var player = get_node("/root/Global").music_player
	if player.stream != level_music or not player.playing:
		player.stream = level_music
		player.play()
