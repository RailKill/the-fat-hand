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
export var speed = 15

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


func _physics_process(delta):
	velocity += gravity_vector * gravity_magnitude * delta
	move()
	velocity = move_and_slide(velocity, Vector3.UP)


# Move player according to directional input.
func move():
	# Preserve jump/fall velocity.
	var vertical = velocity.y
	
	# Add velocity depending on directional input.
	velocity = Vector3()
	for vector in DIRECTIONS:
		if Input.is_action_pressed(vector):
			velocity += DIRECTIONS[vector] * speed
	
	# Restore jump/fall velocity.
	velocity.y = vertical
