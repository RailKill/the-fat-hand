class_name Player
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
var dead_player = preload("res://assets/scenes/characters/player_dead.tscn")
# Game over screen to be shown.
var game_over = preload("res://assets/scenes/ui/gameover.tscn")
# Direction in which the gravity acts in the game world.
var gravity_vector: Vector3 = \
		ProjectSettings.get_setting("physics/3d/default_gravity_vector")
# Strength of the gravity.
var gravity_magnitude = \
		ProjectSettings.get_setting("physics/3d/default_gravity")
# Boolean to mark if the player can still be controlled.
var is_controllable = true
# Boolean to mark if the player is dead.
var is_dead = false
# Current velocity of the player character.
var velocity = Vector3.ZERO

# Animation tree which controls the player's animation.
onready var animation_tree = $AnimationTree
# Player camera.
onready var camera = $Camera
# Controller of the fat hand for punching.
onready var hand = $HandControl
# Grabber zone for grabbing objects.
onready var grabber = $Model/DinoBones/Skeleton/BoneAttachment4/Grabber
# Player model.
onready var model = $Model


func _ready():
	# Start inverse kinematics for the fat hand.
	$Model/DinoBones/Skeleton/SkeletonIK.start()
	# Needed to call this on ready to fix the hand rotation right away.
	hand.fix_roll(model.rotation.y)


func _physics_process(delta):
	if (is_controllable):
		# Simulate gravity.
		velocity += gravity_vector * gravity_magnitude * delta
		
		# Rotate the model if the player moved.
		if(move()):
			# Face model towards direction of movement.
			model.rotation.y = lerp_angle(model.rotation.y, 
					atan2(velocity.x, velocity.z), delta * rotation_speed)
			# Fix hand roll based on player model rotation.
			hand.fix_roll(model.rotation.y)
		
		velocity = move_and_slide(velocity, Vector3.UP)
		animation_tree["parameters/Movement/add_amount"] = \
				velocity.length() / move_speed
	
	# A way for the player to kill themselves.
	if Input.is_action_just_pressed("ui_cancel"):
		die()


# Handle player death and spawn a corpse.
func die():
	if not is_dead:
		is_dead = true
		disable()
		var corpse = dead_player.instance()
		corpse.translation = translation
		corpse.get_node("Model").rotation = model.rotation
		corpse.translate(Vector3.UP * 2)
		fumble(corpse)
		get_parent().call_deferred("add_child", corpse)
		get_parent().call_deferred("add_child", game_over.instance())
		$CollisionShape.disabled = true
		$HandControl/Punch/CollisionShape.disabled = true
		visible = false
		
		# TODO: Hard-coded to make glasses loose. In future, when players can
		# customize what to wear, player.gd should have an Array to store a
		# list of clothes/wearables that will become loose objects on death.
		corpse.connect("ready", self, "drop", [corpse.get_node("Glasses")])


# Stops player control.
func disable():
	is_controllable = false
	hand.disabled = true
	grabber.is_active = false


# Drop given item or article of clothing that this player posseses.
func drop(item):
	var old_transform = item.global_transform
	item.get_parent().remove_child(item)
	get_parent().call_deferred("add_child", item)
	item.global_transform = old_transform
	fumble(item)


# Flip a target RigidBody object around choatically.
func fumble(target: RigidBody, force: Vector3 = velocity):
	target.apply_impulse(Vector3(0.5, 1, 0), force)


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


# Toggles between pain eyes or default eyes.
func toggle_pain_eyes(show):
	$Model/DinoBones/Skeleton/BoneAttachment/EyesCylinder.visible = !show
	$Model/DinoBones/Skeleton/BoneAttachment2/EyesPain.visible = show
