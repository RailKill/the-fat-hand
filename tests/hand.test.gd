extends WAT.Test
# Test for the hand controller which must rotate and point to the right
# direction depending on the location of the controller and rotation of player.


# Hand object to be tested.
var hand


func pre():
	hand = HandController.new()


# Ensure hand is not twisted by matching its y-rotation.
func test_fix_roll():
	describe("fix roll (x-rotation) is correct")
	var expected = 1.5
	hand.fix_roll(expected)
	asserts.is_equal(hand.rotation.y, expected)


# Test if the hand's x rotation for its pointing direction is correct.
# Parameters:
#	x - translation.x of the hand controller.
#	z - translation.z of the hand controller.
#	angle - rotation.y of the hand controller, should follow player model.
#	result - expected rotation.x
func test_fix_yaw():
	describe("fix yaw (y-rotation) is correct")
	parameters([["x", "z", "angle", "result", "context"],
			[-5.0, -5.0, -1.075, -1.3, "facing bottom-left, pointing top-left"],
			[0.8, -3.65, 3.826, -0.9, "facing top-left, pointing top-right"],
			[-0.15, 1.3, 3.138, 3, "facing top, pointing bottom-left"],
			[5, 0, -4.712, 0, "facing right, pointing right"]
	])
	
	hand.translation.x = p["x"]
	hand.translation.z = p["z"]
	hand.rotation.y = p["angle"]
	hand.fix_yaw()
	asserts.is_equal(stepify(hand.rotation.x, 0.1), p["result"], p["context"])


func post():
	hand.queue_free()
