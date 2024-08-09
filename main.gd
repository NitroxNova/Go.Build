@tool
extends Node3D

var pillar_scene = preload("res://House/Pillar/pillar.tscn")
var wall_scene = preload("res://House/Wall/wall.tscn")
var window_scene = preload("res://House/Window/window.glb")
var window_cutout_scene = preload("res://House/Window/cut_out.tscn")

@export var house_config : House_Config :
	set(value):
		print("config changed")
		house_config = value
		house_config.changed.connect(build)
		build()

func _ready():
	build()

func build():
	if is_inside_tree():
		clean_house()
		for p in house_config.pillars:
			build_pillar(p)
		for w in house_config.walls:
			build_wall(w)
		for f in house_config.floors:
			build_floor(f)
		for c in house_config.ceilings:
			build_ceiling(c)
	for mesh in $House.get_children():
		mesh.owner = self
		
func clean_house():
	for child in $House.get_children():
		child.queue_free()

func build_pillar(p_config):
	var pillar = pillar_scene.instantiate()
	pillar.set_position(p_config.position)
	pillar.set_height(p_config.height)
	pillar.set_width(p_config.width)
	pillar.set_material(p_config.material)
	$House.add_child(pillar)
	
func build_wall(wall_config:Wall_Config):
	var wall = wall_scene.instantiate()
	var pillar_1 = house_config.pillars[wall_config.pillar_1]
	var pillar_2 = house_config.pillars[wall_config.pillar_2]
	wall.position = (pillar_1.position + pillar_2.position) / 2
	var length = pillar_1.position.distance_to(pillar_2.position)
	wall.set_length(length)
	var height = min(pillar_1.height,pillar_2.height)
	wall.set_height(height)
	var width = min(pillar_1.width, pillar_2.width)
	width *= wall_config.width
	wall.set_width(width)
	wall.set_material(wall_config.material)
	wall.set_inner_material(wall_config.inner_material)
	var wall_angle = (pillar_1.position - pillar_2.position).angle_to(Vector3.FORWARD)
	if pillar_1.position.x > pillar_2.position.x:
		wall_angle = 2 * PI - wall_angle
	wall.rotation = Vector3(0,wall_angle,0)
	for w in wall_config.windows:
		var window = window_scene.instantiate()
		var cutout = window_cutout_scene.instantiate()
		var window_y = w.vertical_position * height
		var window_z = (w.horizontal_position - 0.5) * length
		var window_position = Vector3(0,window_y,window_z)
		window.position = window_position
		cutout.position = window_position
		cutout.material = wall_config.material
		wall.add_child(cutout)
		wall.add_child(window)
	$House.add_child(wall)

func build_floor(floor_config:Floor_Config):
	var floor = CSGPolygon3D.new()
	floor.material = floor_config.material
	floor.depth = floor_config.thickness
	floor.rotation.x = PI/2
	var floor_poly = PackedVector2Array()
	var height = house_config.pillars[floor_config.perimeter[0]].position.y
	for pillar_id in floor_config.perimeter:
		var pillar = house_config.pillars[pillar_id]
		floor_poly.append(Vector2(pillar.position.x,pillar.position.z))
		if height < pillar.position.y: #get the highest pillar position, so floor will be on stilts if eneven
			height =  pillar.position.y
	floor.polygon = floor_poly #cant append directly to polygon
	floor.position.y = height	
	$House.add_child(floor)
	return floor

func build_ceiling(ceiling_config:Floor_Config):
	var ceiling = build_floor(ceiling_config)
	var first_pillar = house_config.pillars[ceiling_config.perimeter[0]]
	var height = first_pillar.position.y + first_pillar.height - ceiling_config.thickness -.001
	for pillar_id in ceiling_config.perimeter:
		var pillar = house_config.pillars[pillar_id]
		var curr_height = pillar.position.y + pillar.height - ceiling_config.thickness -.001
		if height > curr_height: #get the lowest top position, so ceiling wont be floating if uneven
			height =  curr_height
	ceiling.position.y = height
	

func _on_visibility_changed():
	build()
