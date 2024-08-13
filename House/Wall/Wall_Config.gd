@tool
extends Resource
class_name Wall_Config

@export var pillar_1 : int :
	set(value):
		pillar_1 = value
		emit_changed()

@export var pillar_2 : int:
	set(value):
		pillar_2 = value
		emit_changed()
		
@export var width : float = 1.0:
	set(value):
		width = value
		emit_changed()

@export var proportional_height : float = 0.995:
	set(value):
		proportional_height = value
		emit_changed()
	

@export var windows : Array[Window_Config] :
	set(value):
		windows = value
		for w in windows:
			w.changed.connect(emit_changed)
		emit_changed()

@export var doors : Array[Window_Config] :
	set(value):
		doors = value
		for d in doors:
			d.changed.connect(emit_changed)
		emit_changed()
		
@export var wall_details : Array[Wall_Detail_Config]:
	set(value):
		wall_details = value
		for wd in wall_details:
			wd.changed.connect(emit_changed)
		emit_changed()

@export var material : StandardMaterial3D:
	set(value):
		material = value
		emit_changed()
		

@export var inner_material : StandardMaterial3D:
	set(value):
		inner_material = value
		emit_changed()		

