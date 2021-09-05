extends CSGCylinder
# Just a hacky script to turn a CSG cylinder green. Used as a quick indicator of
# progress since no text is allowed for the game jam.


# Code needed to be received in order to turn green.
export(int) var code = 0


# Make it green.
func on(number):
	if code == number:
		if not material:
			material = SpatialMaterial.new()
		
		material.albedo_color = Color.greenyellow
		if material is SpatialMaterial:
			material.emission_enabled = true
			material.emission = Color.green
