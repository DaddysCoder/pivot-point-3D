extends Node3D
## Procedural Oakhaven field post — Base Hub stations.


@onready var root: Node3D = $Generated


func _ready() -> void:
	for c in root.get_children():
		c.queue_free()
	_build_ground()
	_build_yard()
	_build_buildings()
	_build_props()


func _mat(color: Color, roughness: float = 0.85) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	return m


func _box(size: Vector3, pos: Vector3, color: Color, roughness := 0.85) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = _mat(color, roughness)
	mi.position = pos
	root.add_child(mi)
	var body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	mi.add_child(body)
	body.collision_layer = 1
	return mi


func _cyl(radius: float, height: float, pos: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mi.mesh = mesh
	mi.material_override = _mat(color, 0.7)
	mi.position = pos
	root.add_child(mi)
	var body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	col.shape = shape
	body.add_child(col)
	mi.add_child(body)
	body.collision_layer = 1


func _build_ground() -> void:
	# Soft valley green matching Oakhaven map
	_box(Vector3(100, 1, 100), Vector3(0, -0.5, 0), Color(0.38, 0.50, 0.28), 0.95)
	_box(Vector3(28, 0.15, 28), Vector3(0, 0.05, 0), Color(0.52, 0.46, 0.34), 0.9)
	# Low stone wall ring — grey Highwatch stone
	_box(Vector3(30, 1.2, 0.4), Vector3(0, 0.6, -14), Color(0.58, 0.56, 0.52))
	_box(Vector3(30, 1.2, 0.4), Vector3(0, 0.6, 14), Color(0.58, 0.56, 0.52))
	_box(Vector3(0.4, 1.2, 28), Vector3(-14, 0.6, 0), Color(0.58, 0.56, 0.52))
	_box(Vector3(0.4, 1.2, 28), Vector3(14, 0.6, 0), Color(0.58, 0.56, 0.52))
	_box(Vector3(6, 0.12, 10), Vector3(0, 0.06, 18), Color(0.48, 0.42, 0.32), 0.85)


func _build_yard() -> void:
	_box(Vector3(4, 0.1, 20), Vector3(0, 0.05, 4), Color(0.40, 0.36, 0.30), 0.7)


func _build_buildings() -> void:
	# Timber-framed village tones
	_box(Vector3(9, 3.4, 6.5), Vector3(0, 1.7, -8), Color(0.62, 0.54, 0.42))
	_box(Vector3(9.4, 0.3, 6.9), Vector3(0, 3.5, -8), Color(0.42, 0.28, 0.18))
	_box(Vector3(6, 2.8, 5.5), Vector3(-9, 1.4, -6), Color(0.58, 0.50, 0.40))
	_box(Vector3(8, 3.0, 6), Vector3(9, 1.5, -5), Color(0.50, 0.40, 0.28))
	_box(Vector3(8.4, 0.25, 6.4), Vector3(9, 3.1, -5), Color(0.32, 0.26, 0.20))
	_box(Vector3(5, 2.6, 4), Vector3(9, 1.3, 4), Color(0.44, 0.38, 0.30))
	_box(Vector3(5, 2.4, 4.5), Vector3(-9, 1.2, 3), Color(0.42, 0.48, 0.36))
	_box(Vector3(4.5, 2.5, 4), Vector3(-8, 1.25, 9), Color(0.52, 0.46, 0.38))
	_box(Vector3(5.5, 2.8, 4.5), Vector3(7, 1.4, 9), Color(0.55, 0.48, 0.38))


func _build_props() -> void:
	_cyl(0.1, 8.0, Vector3(-6, 4.0, 9), Color(0.55, 0.55, 0.5))
	for i in range(5):
		_box(Vector3(1.0, 0.9, 1.0), Vector3(3.0 + i * 1.15, 0.45, 5.5), Color(0.45, 0.34, 0.20))
	_box(Vector3(4, 2.4, 4), Vector3(-22, 1.2, 6), Color(0.58, 0.50, 0.38))
	_box(Vector3(4.4, 0.8, 4.4), Vector3(-22, 2.8, 6), Color(0.42, 0.28, 0.18))
	_box(Vector3(3.5, 2.2, 3.5), Vector3(-18, 1.1, 12), Color(0.55, 0.48, 0.36))
	_box(Vector3(3.9, 0.7, 3.9), Vector3(-18, 2.5, 12), Color(0.40, 0.26, 0.16))
