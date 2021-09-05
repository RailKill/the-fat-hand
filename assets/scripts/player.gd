extends KinematicBody
# Player controller.


# Input map to vector directionals.
const DIRECTIONS = {
	"ui_up": Vector3.FORWARD,
	"ui_down": Vector3.BACK,
	"ui_left": Vector3.LEFT,
	"ui_right": Vector3.RIGHT
}

# Movement speed.
export var move_speed = 45
# Rotation speed.
export var rotation_speed = 15

# Dead player asset to be spawned.
var dead_player = preload("res://assets/models/player/dead_player.tscn")
# Game over screen to be shown.
var game_over = preload("res://assets/ui/gameover.tscn")
# Direction in which the gravity acts in the game world.
var gravity_vector: Vector3 = \
		ProjectSettings.get_setting("physics/3d/default_gravity_vector")
# Strength of the gravity.
var gravity_magnitude = \
		ProjectSettings.get_setting("physics/3d/default_gravity")
# Boolean to mark if the player is still alive.
var is_alive = true
# Current velocity of the player character.
var velocity = Vector3.ZERO

# Player camera.
onready var camera = $Camera
# Controller of the fat hand.
onready var hand = $HandControl
# Player model.
onready var model = $Model


func _physics_process(delta):
	if (is_alive):
		# Simulate gravity.
		velocity += gravity_vector * gravity_magnitude * delta
		
		# Rotate the model if the player moved.
		if(move()):
			# Face model towards direction of movement.
			model.rotation.y = lerp_angle(model.rotation.y, 
					atan2(velocity.x, velocity.z), delta * rotation_speed)
			# Fix hand roll based on player model rotation.
			hand.fix_roll(model.rotation_degrees.y)
		
		velocity = move_and_slide(velocity, Vector3.UP)


func _ready():
	# Start inverse kinematics for the fat hand.
	$Model/ArmBones/Skeleton2/SkeletonIK.start()
	# Needed to call this on ready to fix the hand rotation right away.
	hand.fix_roll(model.rotation_degrees.y)


# Player death.
func die():
	is_alive = false
	var corpse = dead_player.instance()
	corpse.translation = translation
	corpse.get_node("Model").rotation = model.rotation
	corpse.translate(Vector3.UP * 2)
	corpse.apply_impulse(Vector3(0.5, 1, 0), velocity)
	get_parent().call_deferred("add_child", corpse)
	get_parent().call_deferred("add_child", game_over.instance())
	$CollisionShape.disabled = true
	$HandControl/Punch/CollisionShape.disabled = true
	visible = false


# Move player according to input. Returns true if direction was pressed.
func move():
	# Preserve jump/fall velocity.
	var vertical = velocity.y
	var is_moving = false
	
	# Add velocity depending on directional input.
	velocity = Vector3()
	for vector in DIRECTIONS:
		if Input.is_action_pressed(vector):
			is_moving = true
			velocity += DIRECTIONS[vector] * move_speed
	
	# Restore jump/fall velocity.
	velocity.y = vertical
	
	return is_moving
