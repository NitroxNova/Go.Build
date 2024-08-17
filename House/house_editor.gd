@tool
extends Node3D
class_name HouseEditor

var pillar_scene = preload("res://addons/HomeMaker/House/Pillar/pillar.tscn")
var wall_scene = preload("res://addons/HomeMaker/House/Wall/wall.tscn")
var window_scene = preload("res://addons/HomeMaker/Models/window.glb")
var window_cutout_scene = preload("res://addons/HomeMaker/cut_outs/cut_out.tscn")
var door_scene = preload("res://addons/HomeMaker/Models/ModelsScenes/door.tscn")
var door_cutout_scene = preload("res://addons/HomeMaker/cut_outs/cut_out_door.tscn")

@export var editing : bool = false :
	set(value):
		editing = value
		build()

@export var hide_ceilings : bool = true :
	set(value):
		hide_ceilings = value
		if editing:
			build()
#@export var hide_house_by_height

@export var house_config : House_Config :
	set(value):
		print("config changed")
		house_config = value
		house_config.changed.connect(build)
		build()

@export_category("Buttons")
## This will make all House_Config unique recursivily for not share blueprints.(testing, do not use)
@export var make_unique_recursive : bool :
	set(value):
		#for p in house_config.pillars:
			#p = p.duplicate(true)
		#for w in house_config.walls:
			#w = w.duplicate(true)
		pass

var t0 : float
var last_pid : Array[int] = []
var last_wid : Array[int] = []
var selection
var count : int = 0
var scene := PackedScene.new()

func _ready():
	visibility_changed.connect(_on_visibility_changed)
	build()

func build():
	t0 = Time.get_ticks_msec()
	if is_inside_tree() and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		selection = EditorInterface.get_selection()
		clean_house()
		for p_id in house_config.pillars.size():
			build_pillar(p_id)
		last_pid.clear()
		count = 0
		for w in house_config.walls:
			build_wall(w)
		for f in house_config.floors:
			build_floor(f)
		for c in house_config.ceilings:
			build_ceiling(c)
		for r in house_config.roofs:
			build_roof(r)
		
		#for mesh in get_children():
				#mesh.owner = owner
	
	print("build in: " + str(Time.get_ticks_msec() - t0) + " msecs.")


func clean_house():
	last_pid.clear()
	last_wid.clear()
	for n in selection.get_selected_nodes():
		if n is Pillar:
			last_pid.append(n.pillar_id)
		if n is Wall:
			last_wid.append(n.w_id)
	for child in get_children():
		child.queue_free()

func build_pillar(p_id:int):
	var pillar = pillar_scene.instantiate()
	pillar.pillar_id = p_id
	var p_config:Pillar_Config = house_config.pillars[p_id]
	pillar.pillar_config = p_config
	pillar.set_position(p_config.position)
	pillar.set_height(p_config.height)
	pillar.set_width(p_config.width)
	pillar.set_material(p_config.material)
	add_child(pillar)
	pillar.transform_changed.connect(pillar_transform_changed)
	if editing:
		pillar.owner = owner
		pillar.pillar_id = p_id
		pillar.name = "Pillar_" + str(p_id) + "_" + str(pillar.position) +"   ; p   " + str(randi_range(0, 25))
		if last_pid.size() > 0 and last_pid.has(p_id): # keep pillar selected.
			selection.add_node(pillar)
			last_pid.erase(p_id)

func pillar_transform_changed(pillar_id:int,pos:Vector3):
	house_config.pillars[pillar_id].position = pos
	
func build_wall(wall_config:Wall_Config):
	var wall = wall_scene.instantiate()
	wall.wall_config = wall_config
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
	for d in wall_config.doors:
		var door = door_scene.instantiate()
		var cutout = door_cutout_scene.instantiate()
		var door_y = d.vertical_position * height
		var door_z = (d.horizontal_position - 0.5) * length
		var door_position = Vector3(0,door_y,door_z)
		door.position = door_position
		cutout.position = door_position
		cutout.material = wall_config.material
		wall.add_child(cutout)
		wall.add_child(door)
	for wd in wall_config.wall_details:
		if wd.wall_detail == null:
			continue
		var door_y = wd.vertical_position * height
		var door_z = (wd.horizontal_position - 0.5) * length
		var wd_position = Vector3(0,door_y,door_z)
		if wd.wall_detail.cut_out != null:
			var cutout = wd.wall_detail.cut_out.instantiate()
			cutout.position = wd_position
			if cutout is CSGPrimitive3D:
				cutout.material = wall_config.material 
			for m in cutout.get_children():
				if m is CSGPrimitive3D:
					m.material = wall_config.material
			wall.add_child(cutout)
		if wd.wall_detail.model != null:
			var detail = wd.wall_detail.model.instantiate()
			detail.position = wd_position
			wall.add_child(detail)
	add_child(wall)
	if editing:
		wall.owner = owner
		wall.w_id = count
		wall.name = "Wall_" + str(count) + "   <3   " + str(randi_range(0, 25))
		if last_wid != null and last_wid.has(count):
			selection.add_node(wall)
			last_wid.erase(count)
	count += 1
	

func build_floor(floor_config:Floor_Config):
	var c_floor = CSGPolygon3D.new()
	c_floor.material = floor_config.material
	c_floor.depth = floor_config.thickness
	c_floor.rotation.x = PI/2
	if floor_config.scale <= 0.0:
		floor_config.scale = 1.0
	c_floor.scale = Vector3(floor_config.scale, floor_config.scale, 1.0)
	var floor_poly = PackedVector2Array()
	var height = house_config.pillars[floor_config.perimeter[0]].position.y
	for pillar_id in floor_config.perimeter:
		var pillar = house_config.pillars[pillar_id]
		floor_poly.append(Vector2(pillar.position.x,pillar.position.z))
		if height < pillar.position.y: #get the highest pillar position, so floor will be on stilts if eneven
			height =  pillar.position.y
	c_floor.polygon = floor_poly #cant append directly to polygon
	c_floor.position.y = height
	c_floor.set_use_collision(true)
	add_child(c_floor)
	return c_floor

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
	if editing and hide_ceilings:
		ceiling.visible = false

func build_roof(roof_config:Roof_Config):
	var roof_mesh = ArrayMesh.new()
	var sf_arrays = []
	sf_arrays.resize(Mesh.ARRAY_MAX)
	sf_arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	sf_arrays[Mesh.ARRAY_INDEX] = PackedInt32Array()
	var perimeter : PackedVector3Array = []
	var interior : PackedVector3Array = []
	var perim_inter_connect = [] #perimeter and interior connections , so we can fill in the gaps in the roof
	for i in roof_config.perimeter.size():
		perim_inter_connect.append({})
	for p in roof_config.perimeter:
		var top_pos = house_config.pillars[p].get_top_position()
		perimeter.append(top_pos)
		sf_arrays[Mesh.ARRAY_VERTEX].append(top_pos)
	for p in roof_config.interior:
		var top_pos = house_config.pillars[p].get_top_position() + (Vector3.UP * 0.1)
		interior.append(top_pos)
		sf_arrays[Mesh.ARRAY_VERTEX].append(top_pos)
	
	for curr_id in perimeter.size():
		sf_arrays[Mesh.ARRAY_INDEX].append(curr_id)
		var next_id = curr_id+1
		if next_id == perimeter.size():
			next_id = 0
		sf_arrays[Mesh.ARRAY_INDEX].append(next_id)
		var mid_point = (perimeter[curr_id] + perimeter[next_id])/2
		var closest_interior = 0
		for i in range(1,interior.size()):
			if interior[i].distance_to(mid_point) < interior[closest_interior].distance_to(mid_point):
				closest_interior = i
		closest_interior+=perimeter.size()
		sf_arrays[Mesh.ARRAY_INDEX].append(closest_interior)
		perim_inter_connect[curr_id][closest_interior] = true
		perim_inter_connect[next_id][closest_interior] = true
		
	for perim_id in perim_inter_connect.size():
		var connections = perim_inter_connect[perim_id]
		if connections.size() == 2:
			var keys = connections.keys()
			keys.reverse()
			for inter_id in keys:
				sf_arrays[Mesh.ARRAY_INDEX].append(int(inter_id))
			sf_arrays[Mesh.ARRAY_INDEX].append(int(perim_id))
		elif connections.size() > 2:
			printerr("Dont know how to handle more than 2 connections")
		
	print(sf_arrays[Mesh.ARRAY_INDEX])
	roof_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,sf_arrays)
	roof_mesh.surface_set_material(0,roof_config.material)
	
	var mi = CSGMesh3D.new()
	mi.mesh = roof_mesh
	add_child(mi)
	mi.name = "Roof"
	#mi.owner = owner
	
func _on_visibility_changed():
	build()
