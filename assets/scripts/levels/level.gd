class_name Level
extends Spatial
# Each level in this game should have this script attached.


# The music that will play when this level loads.
export(AudioStream) var level_music


func _ready():
	var player = Global.music_player
	if player.stream != level_music or not player.playing:
		player.stream = level_music
		player.play()


# Changes the volume of the given bus index to the given value.
func adjust_volume(value: float, bus_index: int):
	AudioServer.set_bus_mute(bus_index, value <= 0)
	AudioServer.set_bus_volume_db(bus_index, value / 2 - 50)
	Global.set_option("sound", 
			"%s_volume" % Global.BUS_DICTIONARY[bus_index], value)


# Changes to the given scene with a delay in seconds.
func change_scene(path, delay = 1.0):
	var tree = get_tree()
	tree.create_timer(delay).connect("timeout", tree, "change_scene", [path])


# Returns the percentage volume for the given audio bus, and if there is a
# given node_path, find it and call set_percentage() on it.
func load_volume(bus_index: int, node_path = null):
	var volume = Global.options.get_value("sound", 
			"%s_volume" % Global.BUS_DICTIONARY[bus_index], 50)
	var control = get_node_or_null(node_path)
	if control and control.has_method("set_percentage"):
		control.set_percentage(volume)
	return volume
