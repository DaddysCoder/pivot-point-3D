extends Node3D
## Builds a stylised Frontier compound at runtime — Phase 1 environment feel.
## No checkerboard grids. Believable proportions, golden-hour lighting props.


@onready var root: Node3D = $Generated


func _ready() -> void:
	_clear_generated()
	_build_ground()
	_build_road()
	_build_fence()
	_build_buildings()
	_build_props()
	_build_scrub()


func _clear_generated() -> void:
	for child in root.get_children():
		child.queue_free()


func _mat(color: Color, roughness: float = 0.85, metallic: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	m.metallic = metallic
	return m


func _box(size: Vector3, pos: Vector3, color: Color, parent: Node3D = null, roughness := 0.85) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = _mat(color, roughness)
	mi.position = pos
	(parent if parent else root).add_child(mi)
	var body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	mi.add_child(body)
	body.collision_layer = 1
	return mi


func _cylinder(radius: float, height: float, pos: Vector3, color: Color, parent: Node3D = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mi.mesh = mesh
	mi.material_override = _mat(color, 0.7)
	mi.position = pos
	(parent if parent else root).add_child(mi)
	var body := StaticBody3D.new()
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height
	col.shape = shape
	body.add_child(col)
	mi.add_child(body)
	body.collision_layer = 1
	return mi


func _build_ground() -> void:
	# Broad dry terrain plane with slight colour variation via large boxes as berms.
	_box(Vector3(120, 1, 120), Vector3(0, -0.5, 0), Color(0.55, 0.48, 0.34), null, 0.95)
	_box(Vector3(40, 2.5, 18), Vector3(-28, 0.4, -22), Color(0.50, 0.42, 0.30), null, 0.95)
	_box(Vector3(22, 3.5, 30), Vector3(32, 0.8, 8), Color(0.48, 0.40, 0.28), null, 0.95)
	_box(Vector3(50, 1.2, 14), Vector3(0, -0.2, 28), Color(0.42, 0.46, 0.36), null, 0.9) # scrub edge


func _build_road() -> void:
	_box(Vector3(8, 0.12, 70), Vector3(0, 0.06, 5), Color(0.28, 0.27, 0.25), null, 0.7)
	_box(Vector3(28, 0.12, 7), Vector3(8, 0.06, -18), Color(0.28, 0.27, 0.25), null, 0.7)
	# Dirt track alternate
	_box(Vector3(4.5, 0.08, 36), Vector3(-14, 0.04, 8), Color(0.45, 0.36, 0.24), null, 0.95)


func _build_fence() -> void:
	for i in range(-5, 6):
		_box(Vector3(0.12, 1.4, 0.12), Vector3(-18, 0.7, i * 4.0), Color(0.35, 0.32, 0.28))
		_box(Vector3(0.12, 1.4, 0.12), Vector3(18, 0.7, i * 4.0), Color(0.35, 0.32, 0.28))
	_box(Vector3(36, 0.08, 0.08), Vector3(0, 1.15, -20), Color(0.4, 0.36, 0.3))
	_box(Vector3(36, 0.08, 0.08), Vector3(0, 0.55, -20), Color(0.4, 0.36, 0.3))
	_box(Vector3(0.08, 0.08, 40), Vector3(-18, 1.15, 0), Color(0.4, 0.36, 0.3))
	_box(Vector3(0.08, 0.08, 40), Vector3(18, 1.15, 0), Color(0.4, 0.36, 0.3))


func _build_buildings() -> void:
	# Command building
	_box(Vector3(10, 3.2, 7), Vector3(-6, 1.6, -8), Color(0.62, 0.58, 0.48), null, 0.8)
	_box(Vector3(10.4, 0.25, 7.4), Vector3(-6, 3.3, -8), Color(0.35, 0.32, 0.28), null, 0.75)
	# Workshop shed
	_box(Vector3(8, 2.8, 6), Vector3(8, 1.4, -6), Color(0.45, 0.38, 0.30), null, 0.75)
	_box(Vector3(8.6, 0.2, 6.6), Vector3(8, 2.9, -6), Color(0.30, 0.28, 0.25))
	# Storage containers
	_box(Vector3(5.5, 2.4, 2.4), Vector3(10, 1.2, 4), Color(0.25, 0.42, 0.38), null, 0.55)
	_box(Vector3(5.5, 2.4, 2.4), Vector3(10, 1.2, 7.2), Color(0.42, 0.32, 0.22), null, 0.55)
	# Map room lean-to
	_box(Vector3(5, 2.6, 5), Vector3(-10, 1.3, 2), Color(0.58, 0.54, 0.45), null, 0.8)


func _build_props() -> void:
	# Radio mast
	_cylinder(0.12, 9.0, Vector3(4, 4.5, 2), Color(0.55, 0.55, 0.52))
	_box(Vector3(0.8, 0.2, 0.8), Vector3(4, 9.0, 2), Color(0.7, 0.45, 0.2))
	# Floodlight poles
	_cylinder(0.08, 4.5, Vector3(-12, 2.25, -14), Color(0.4, 0.4, 0.38))
	_box(Vector3(0.6, 0.25, 0.4), Vector3(-12, 4.5, -14), Color(0.85, 0.8, 0.65), null, 0.4)
	_cylinder(0.08, 4.5, Vector3(14, 2.25, -12), Color(0.4, 0.4, 0.38))
	_box(Vector3(0.6, 0.25, 0.4), Vector3(14, 4.5, -12), Color(0.85, 0.8, 0.65), null, 0.4)
	# Crates
	for i in range(4):
		_box(Vector3(1.1, 1.0, 1.1), Vector3(-2.0 + i * 1.3, 0.5, 6.5), Color(0.42, 0.32, 0.20))
	# Utility vehicle placeholder (static)
	_box(Vector3(4.2, 1.6, 2.0), Vector3(2, 0.9, 12), Color(0.32, 0.36, 0.28), null, 0.55)
	_box(Vector3(1.8, 0.9, 1.9), Vector3(0.6, 1.85, 12), Color(0.25, 0.28, 0.24), null, 0.5)
	_cylinder(0.45, 0.35, Vector3(0.7, 0.45, 10.9), Color(0.12, 0.12, 0.12))
	_cylinder(0.45, 0.35, Vector3(0.7, 0.45, 13.1), Color(0.12, 0.12, 0.12))
	_cylinder(0.45, 0.35, Vector3(3.2, 0.45, 10.9), Color(0.12, 0.12, 0.12))
	_cylinder(0.45, 0.35, Vector3(3.2, 0.45, 13.1), Color(0.12, 0.12, 0.12))


func _build_scrub() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in range(40):
		var x := rng.randf_range(-50.0, 50.0)
		var z := rng.randf_range(-50.0, 50.0)
		if absf(x) < 20.0 and absf(z) < 22.0:
			continue
		var h := rng.randf_range(0.4, 1.3)
		_box(Vector3(0.35, h, 0.35), Vector3(x, h * 0.5, z), Color(0.30, 0.38, 0.22), null, 0.95)
