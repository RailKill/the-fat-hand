extends Spatial


export(float, 3, 12) var limit = 10.5

onready var knob = $Knob


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(_delta):
	if abs(knob.translation.x) > limit:
		knob.mode = RigidBody.MODE_KINEMATIC
		knob.translation.x = clamp(knob.translation.x, -limit + 1, limit - 1)
		knob.mode = RigidBody.MODE_RIGID
	print(knob.translation.x)
