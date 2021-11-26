extends BoundedBody
# Heavy object that must be damaged by attacks before it becomes a rigidbody.


# Amount of hit points this entity has.
export(int) var hp = 100
export(AudioStream) var hit_sound

# The Area to detect for attacks.
var area
# AudioStreamPlayer3D which plays a sound when damaged.
var hit_player


func _ready():
	collision_layer = 0
	collision_mask = Global.ENVIRONMENT_LAYER + \
			Global.CHARACTER_LAYER + Global.PROP_LAYER
	area = Area.new()
	area.connect("body_entered", self, "_on_body_entered")
	area.add_child($CollisionShape.duplicate())
	add_child(area)
	
	hit_player = AudioStreamPlayer3D.new()
	hit_player.stream = hit_sound
	hit_player.unit_size = 3
	add_child(hit_player)


# Called when an attack enters the damage area.
func _on_body_entered(body):
	if body.is_in_group("attack"):
		# TODO: Needs to be enforced, it's possible that a body of the "attack"
		# group may not have a parent that has the power attribute.
		take_damage(body.get_parent().power)


# Checks if this entity is destroyed.
func is_destroyed():
	return hp <= 0


# Take the given amount of damage and become rigid if destroyed.
func take_damage(amount):
	hp -= amount
	hit_player.play()
	
	if is_destroyed():
		mode = RigidBody.MODE_RIGID
		collision_layer = Global.ENVIRONMENT_LAYER + Global.PROP_LAYER
		area.queue_free()
