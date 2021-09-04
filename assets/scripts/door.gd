extends RigidBody


# Amount of hit points this entity has.
export var hp = 100
# The area to detect for attacks.
onready var area = $Area


func _ready():
	area.connect("body_entered", self, "_on_body_entered")


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
	$AudioStreamPlayer3D.play()
	
	if is_destroyed():
		mode = RigidBody.MODE_RIGID
		collision_layer = 1
		area.queue_free()
