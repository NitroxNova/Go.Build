@tool
extends Node3D
class_name Pillar
var pillar_id : int
signal transform_changed

@export var pillar_config : Pillar_Config

func _ready():
	set_notify_transform(true)

func set_height(height:float):
	$Mesh.height = height
	$Mesh.position.y = height/2

	
func set_material(material):
	$Mesh.material = material

func set_width(width:float):
	$Mesh.radius = width / 2

func _notification(notification:int):
	if(notification == NOTIFICATION_TRANSFORM_CHANGED):
		transform_changed.emit(pillar_id,position)

