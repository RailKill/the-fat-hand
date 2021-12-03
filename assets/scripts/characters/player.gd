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

# Start-stop dampening of movement.
export var inertia = 0.2
# Jump strength.
export var jump_strength = 20
# Movement speed.
export var move_speed = 45
# Rotation speed.
export var rotation_speed = 15

# Dead player asset to be spawned.
var dead_player = preload("res://assets/scenes/characters/player_dead.tscn")
# Game over screen to be shown.
var game_over = preload("res://assets/scenes/ui/gameover.tscn")
# Direction in which the gravity acts in the game world.
var gravity_vector = ProjectSettings.get_setting(
		"physics/3d/default_gravity_vector")
# Strength of the gravity.
var gravity_magnitude = ProjectSettings.get_setting(
		"physics/3d/default_gravity")
# Boolean to mark if the player can still be controlled.
var is_controllable = true
# Boolean to mark if the player is dead.
var is_dead = false
# Delay timer for jump cooldown.
var jump_delay: Timer
# Current velocity of the player character.
var velocity = Vector3.ZERO

# Animation tree which controls the player's animation.
onready var animation_tree = $AnimationTree
# Player camera.
onready var camera = $Camera
# Area to detect if player is standing on something.
onready var foothold = $Foothold
# Grabber zone for grabbing objects.
onready var grabber = $Model/DinoBones/Skeleton/BoneAttachment4/Grabber
# Controller of the fat hand for punching.
onready var hand = $HandControl
# Hand skeleton inverse kinematics.
onready var ik = $Model/DinoBones/Skeleton/SkeletonIK
# Player model.
onready var model = $Model

onready var audio_jump = get_node_or_null("Foothold/AudioJump")


func _ready():
	# Perform throw if grab is released.
	grabber.connect("grab_released", self, "throw")
	# Start inverse kinematics for the fat hand.
	ik.start()
	# Needed to call this on ready to fix the hand rotation right away.
	hand.fix_roll(model.rotation.y)
	
	# Setup jump cooldown timer.
	jump_delay = Timer.new()
	jump_delay.wait_time = 0.1
	jump_delay.one_shot = true
	add_child(jump_delay, true)


func _physics_process(delta):
	simulate_gravity(delta)
	dampen()
	if (is_controllable):
		# Handle jumping.
		if Input.is_action_pressed("jump") and is_on_ground() \
				and jump_delay.time_left == 0:
			jump()
		
		if move():
			# Face model towards direction of movement.
			model.rotation.y = lerp_angle(model.rotation.y, 
					atan2(velocity.x, velocity.z), delta * rotation_speed)
			# Fix hand roll based on player model rotation.
			hand.fix_roll(model.rotation.y)
		
		# Vector3.DOWN is treated as UP in move_and_slide() to prevent
		# flying off steep slopes.
		velocity = move_and_slide(velocity, Vector3.DOWN)
		animation_tree.set("parameters/Movement/add_amount",
				velocity.length() / move_speed)
	
	# A way for the player to kill themselves.
	if Input.is_action_just_pressed("ui_cancel"):
		die()


# Dampen xz movement using inertia.
func dampen():
	velocity.x = lerp(velocity.x, 0, inertia)
	velocity.z = lerp(velocity.z, 0, inertia)


# Handle player death and spawn a corpse.
func die(show_gameover = true):
	if not is_dead:
		is_dead = true
		disable()
		var corpse = dead_player.instance()
		corpse.translation = translation
		corpse.get_node("Model").rotation = model.rotation
		corpse.translate(Vector3.UP * 2)
		throw(corpse, velocity)
		get_parent().call_deferred("add_child", corpse, true)
		$CollisionShape.disabled = true
		$HandControl/Puncher/CollisionShape.disabled = true
		visible = false
		
		# Show game over UI.
		if show_gameover:
			get_parent().call_deferred("add_child", game_over.instance(), true)
		
		# TODO: Hard-coded to make glasses loose. In future, when players can
		# customize what to wear, player.gd should have an Array to store a
		# list of clothes/wearables that will become loose objects on death.
		corpse.connect("ready", self, "drop", [corpse.get_node("Glasses")])


# Stops player control.
func disable():
	ik.stop()
	is_controllable = false
	hand.is_enabled = false
	if grabber.is_grabbing and grabber.highlighted:
		grabber.release()
	grabber.is_active = false
	grabber.clear()


# Drop given item or article of clothing that this player posseses.
func drop(item):
	var old_transform = item.global_transform
	item.get_parent().remove_child(item)
	get_parent().call_deferred("add_child", item)
	item.global_transform = old_transform
	throw(item, velocity)


# Regain player control.
func enable():
	ik.start()
	is_controllable = true
	hand.is_enabled = true
	grabber.is_active = true


# Checks if the player is on the ground or on some object.
func is_on_ground():
	return foothold.get_overlapping_bodies().size() > 0 or is_on_ceiling()


# Launches the player upward.
func jump():
	jump_delay.start()
	suspend()
	velocity += -gravity_vector * jump_strength
	if not animation_tree.get("parameters/Jumping/active"):
		animation_tree.set("parameters/Jumping/active", true)
		animation_tree.set("parameters/Air/conditions/landed", false)
	audio_jump.play()


# Move player according to input. Returns true if direction was pressed.
func move():
	var motion = InputHandler.get_vector(JOY_AXIS_0, JOY_AXIS_1) * \
			move_speed * inertia
	var horizontal = velocity * (Vector3.RIGHT + Vector3.BACK)
	var vertical = velocity * Vector3.UP
	if (horizontal + motion).length() > move_speed:
		velocity = motion.normalized() * move_speed + vertical
	else:
		velocity = horizontal + motion + vertical
	return motion


# Simulate gravity and falling velocity of the player given delta time passed.
func simulate_gravity(delta):
	if is_on_ground() and jump_delay.is_stopped():
		suspend()
		# Play landing animation if player was jumping.
		if animation_tree.get("parameters/Jumping/active"):
			animation_tree.set("parameters/Air/conditions/landed", true)
	else:
		velocity += gravity_vector * gravity_magnitude * delta


# Suspends the player's gravity by zeroing the falling velocity.
func suspend():
	velocity *= Vector3.ONE - gravity_vector.abs()


# Flip a target RigidBody object with given force around given position.
func throw(target, force = velocity / 2 + hand.power * \
		global_transform.origin.direction_to(hand.global_transform.origin),
		position = Vector3(0.5, 1, 0)):
	target.apply_impulse(position, force)


# Toggles between pain eyes or default eyes.
func toggle_pain_eyes(show):
	$Model/DinoBones/Skeleton/BoneAttachment/EyesCylinder.visible = !show
	$Model/DinoBones/Skeleton/BoneAttachment2/EyesPain.visible = show
