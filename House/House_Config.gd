@tool
extends Resource
class_name House_Config

@export var pillars : Array[Pillar_Config] :
	set(value):
		pillars = value
		for p in pillars:
			p.changed.connect(emit_changed)
		emit_changed()
		
@export var walls : Array[Wall_Config] :
	set(value):
		walls = value
		for w in walls:
			w.changed.connect(emit_changed)
		emit_changed()

@export var floors : Array[Floor_Config] :
	set(value):
		floors = value
		for f in floors:
			f.changed.connect(emit_changed)
		emit_changed()
	
@export var ceilings : Array[Floor_Config] :
	set(value):
		ceilings = value
		for c in ceilings:
			c.changed.connect(emit_changed)
		emit_changed()

@export var roofs : Array[Roof_Config] :
	set(value):
		roofs = value
		for r in roofs:
			r.changed.connect(emit_changed)
		emit_changed()
	
