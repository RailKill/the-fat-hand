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
export var move_speed = 15
# Rotation speed.
export var rotation_speed = 15

# Direction in which the gravity acts in the game world.
var gravity_vector: Vector3 = \
		ProjectSettings.get_setting("physics/3d/default_gravity_vector")
# Strength of the gravity.
var gravity_magnitude = \
		ProjectSettings.get_setting("physics/3d/default_gravity")
# Current velocity of the player character.
var velocity = Vector3.ZERO

# Player camera.
onready var camera = $Camera
# Player model.
onready var model = $Model


func _physics_process(delta):
	# Simulate gravity.
	velocity += gravity_vector * gravity_magnitude * delta
	
	# Rotate the model if the player moved.
	if(move()):
		# Face model towards direction of movement.
		model.rotation.y = lerp_angle(model.rotation.y, 
				atan2(velocity.x, velocity.z), delta * rotation_speed)
		
		# TODO: Fix hand roll based on player model rotation.
	
	velocity = move_and_slide(velocity, Vector3.UP)


func _ready():
	$Model/ArmBones/Skeleton2/SkeletonIK.start()


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
