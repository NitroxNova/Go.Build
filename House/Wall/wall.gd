@tool
extends CSGCombiner3D
class_name Wall

@export var wall_config : Wall_Config

var w_id := 0

func set_length(length:float):
	$Mesh.size.z = length
	$Inner.size.z = length
	
func set_height(height:float):
	var y_size = height * wall_config.proportional_height
	$Mesh.size.y = y_size
	$Mesh.position.y = y_size/2
	$Inner.size.y = y_size
	$Inner.position.y = y_size/2
	
func set_width(width:float):
	$Mesh.size.x = width
	$Inner.position.x = width /2
	
func set_material(material):
	$Mesh.material = material
	
func set_inner_material(material):
	if material == null:
		$Inner.hide()
	else:
		$Inner.show()
		$Inner.material = material
