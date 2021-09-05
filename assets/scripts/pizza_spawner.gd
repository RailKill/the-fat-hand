extends Spatial


var pizza = preload("res://assets/models/props/food/pizza.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var pizzas = get_node("/root/Global").number_of_wins
	for _i in range(pizzas):
		var instance = pizza.instance()
		instance.translate(Vector3(rand_range(-5, 5), 0, rand_range(-5, 5)))
		add_child(instance)
