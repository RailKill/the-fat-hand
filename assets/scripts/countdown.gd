extends Control
# Countdown timer with UI which updates every tick and can trigger something
# when it reaches 0.


# Emitted when the countdown timer expires.
signal expired


# Starting time of the countdown in seconds.
export var start_time = 15

# Current time of the countdown timer.
var current_time

# The label which displays the remaining time.
onready var label = $WatchBody/Label
# Recurring timer node.
onready var timer = $Timer


func _ready():
	current_time = start_time
	update_time()
	timer.connect("timeout", self, "tick")


# Start the countdown.
func start():
	timer.start()


# Called every timer tick (per second).
func tick():
	current_time -= timer.wait_time
	update_time()
	print(current_time)
	
	if current_time <= 0:
		timer.stop()
		emit_signal("expired")


# Updates the label text to the current time.
func update_time():
	label.text = str(current_time)
