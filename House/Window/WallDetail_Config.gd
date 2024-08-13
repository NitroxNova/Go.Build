extends Resource

class_name Wall_Detail_Config

@export var horizontal_position : float = 0.5:
	set(value):
		horizontal_position = value
		emit_changed()

@export var vertical_position : float = 0.5:
	set(value):
		vertical_position = value
		emit_changed()

@export var wall_detail : WallDetail:
	set(value):
		wall_detail = value
		wall_detail.cut_out.changed.connect(emit_changed)
		wall_detail.model.changed.connect(emit_changed)
		emit_changed()
