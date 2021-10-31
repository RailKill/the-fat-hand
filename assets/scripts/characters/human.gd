extends RigidBody


# If true, this human will not roam.
export(bool) var always_idle = false
export(int) var walk_speed = 200

var is_hit = false
var is_walking = false

onready var animation_player = $Model/AnimationPlayer
onready var timer = $Timer


func _ready():
	animation_player.get_animation("Idle").loop = true
	animation_player.get_animation("Walk").loop = true
	randomize()
	
	if always_idle:
		timer.queue_free()


func _physics_process(_delta):
	# If NPC wants to go somewhere, move forward.
	if is_walking:
		add_central_force(-global_transform.basis.z * walk_speed)


func _on_decision():
	timer.wait_time = rand_range(0.6, 2.8)
	if randi() % 2:
		is_walking = true
		animation_player.play("Walk")
		rotation_degrees.y = randi() % 360
	else:
		is_walking = false
		animation_player.play("Idle")


# Triggers when the NPC interacts with another physics object.
func _on_hit(body):
	if body.is_in_group("attack"):
		is_walking = false
		is_hit = true
		animation_player.stop(false)
		$AudioStreamPlayer3D.play()
		axis_lock_angular_x = false
		axis_lock_angular_y = false
		axis_lock_angular_z = false
		$StaticBody.queue_free()
		$Area.queue_free()
		
		if is_instance_valid(timer):
			timer.queue_free()
