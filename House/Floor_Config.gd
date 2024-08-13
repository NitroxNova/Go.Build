@tool
extends Resource
class_name Floor_Config

@export var perimeter : PackedInt32Array:
	set(value):
		perimeter = value
		emit_changed()

@export var thickness : float = .1:
	set(value):
		thickness = value
		emit_changed()

@export var material : StandardMaterial3D:
	set(value):
		material = value
		emit_changed()

@export var scale: float = 1.0:
	set(value):
		scale = value
		emit_changed()
