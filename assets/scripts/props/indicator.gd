extends GeometryInstance
# Just a hacky script to turn a CSGPrimitive or MeshInstance a bright color. 
# Used as a quick indicator of sorts to notify the player of something.


# Code needed to be received in order to turn a bright color.
export(int) var code = 0
# Color of the indicator.
export(Color) var color = Color.greenyellow

# If it is a CSGPrimitive, the default material needs to be stored and set
# because GeometryInstance's override does not affect it.
onready var default_material = get("material")
# Indicator may have a light node attached to it that can illuminate the area.
onready var lighting = get_node_or_null("Light")


# Change the material.
func on(number):
	if code == number:
		var new_material = SpatialMaterial.new()
		new_material.albedo_color = color
		new_material.emission_enabled = true
		new_material.emission = color
		
		material_override = new_material
		set("material", new_material)
		if lighting:
			lighting.visible = true


# Restore default material.
func off():
	material_override = null
	set("material", default_material)
	if lighting:
		lighting.visible = false
