extends Resource
class_name  WallDetail

@export var cut_out : PackedScene :
	set(value):
		cut_out = value
		emit_changed()
	
@export var model : PackedScene :
	set(value):
		model = value
		emit_changed()
