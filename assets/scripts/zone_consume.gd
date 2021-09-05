class_name ZoneConsume
extends ZoneVictory


# Emits whenever a good item is consumed.
signal consumed_good(number)


# Sound to make when a bad item is consumed.
export(AudioStream) var consume_sound_bad
# Sound to make when a good item is consumed.
export(AudioStream) var consume_sound_good
# Maximum amount of bad consumptions before triggering player death.
export(int) var maximum_bad_consumption = 3
# Required amount of good consumptions for victory.
export(int) var required_consumption = 3
# NodePath to Player.
export(NodePath) var player_path

# Total number of bads consumed.
var bads_consumed = 0
# AudioStreamPlayer3D for the bad sound.
var bad_player
# Total number of goods consumed.
var goods_consumed = 0
# AudioStreamPlayer3D for the good sound.
var good_player


func _ready():
	bad_player = AudioStreamPlayer3D.new()
	bad_player.stream = consume_sound_bad
	bad_player.unit_db = 3
	add_child(bad_player)
	good_player = AudioStreamPlayer3D.new()
	good_player.stream = consume_sound_good
	good_player.unit_db = 3
	add_child(good_player)


# Override and check for props to consume.
func _on_body_entered(body):
	if body.is_in_group("ingredient"):
		body.call_deferred("free")
		if body.is_in_group("pizza"):
			# om nom nom
			goods_consumed += 1
			good_player.play()
			emit_signal("consumed_good", goods_consumed)
			if goods_consumed >= required_consumption:
				._on_body_entered(get_node(player_path))
		elif body.is_in_group("vegetable"):
			# ignore veggies
			good_player.play()
		else:
			bads_consumed += 1
			bad_player.play()
	
	if body is Player or bads_consumed >= maximum_bad_consumption:
		get_node(player_path).die()
		countdown.stop()
