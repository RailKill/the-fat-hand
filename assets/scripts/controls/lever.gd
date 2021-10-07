extends Spatial


export(float, 3, 12) var limit = 10.5

onready var knob = $Knob


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(_delta):
	if abs(knob.translation.x) > limit:
		knob.mode = RigidBody.MODE_KINEMATIC
		print(knob.translation.x)
		knob.translation.x = clamp(knob.translation.x, -limit + 1, limit - 1)
		knob.mode = RigidBody.MODE_RIGID
	
	if not knob.sleeping:
		var adjusted = limit - 1
		var positivize = knob.translation.x + adjusted
		var volume = positivize / (adjusted * 2) * 100 if positivize else 0
		adjust_volume(1, volume)
		


func adjust_volume(bus_index: int, value: float):
	AudioServer.set_bus_mute(bus_index, value <= 0)
	AudioServer.set_bus_volume_db(bus_index, value / 2 - 50)
	#print(AudioServer.get_bus_volume_db(1))


func _on_Knob_sleeping_state_changed():
	print("is sleeping: " + str(knob.sleeping))
