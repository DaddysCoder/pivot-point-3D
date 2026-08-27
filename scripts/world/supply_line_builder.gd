extends Node3D
## Kingsroad → destroyed bridge → Highwatch greybox theatre.


@onready var root: Node3D = $Generated

signal crossing_ready(marker: Node3D)


func _ready() -> void:
	for c in root.get_children():
		c.queue_free()
	_build_terrain()
	_build_kingsroad()
	_build_river_and_bridge()
	_build_village()
	_build_highwatch()
	_build_scrub()
	var marker := Node3D.new()
	marker.name = "CrossingMarker"
	marker.position = Vector3(0, 0, -28)
	root.add_child(marker)
	crossing_ready.emit(marker)


func _mat(color: Color, roughness: float = 0.85, metallic: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	m.metallic = metallic
	return m


func _water_mat(color: Color) -> StandardMaterial3D:
	var m := _mat(color, 0.15)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color.a = 0.82
	return m


func _box(size: Vector3, pos: Vector3, color: Color, roughness := 0.85, collide := true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = _mat(color, roughness)
	mi.position = pos
	root.add_child(mi)
	if collide:
		var body := StaticBody3D.new()
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		col.shape = shape
		body.add_child(col)
		mi.add_child(body)
		body.collision_layer = 1
	return mi


func _build_terrain() -> void:
	_box(Vector3(160, 1, 180), Vector3(0, -0.5, -20), Color(0.40, 0.50, 0.30), 0.95)
	# Hills toward Ironpeak (north-west)
	_box(Vector3(40, 8, 30), Vector3(-45, 3.5, -70), Color(0.45, 0.48, 0.42), 0.9)
	_box(Vector3(28, 12, 22), Vector3(-55, 5.5, -85), Color(0.70, 0.72, 0.75), 0.85)
	# Marsh hint east
	_box(Vector3(35, 0.4, 40), Vector3(42, -0.1, -40), Color(0.28, 0.40, 0.32), 0.95)


func _build_kingsroad() -> void:
	_box(Vector3(7, 0.14, 90), Vector3(0, 0.07, 10), Color(0.42, 0.40, 0.36), 0.65)
	_box(Vector3(7, 0.14, 50), Vector3(0, 0.07, -55), Color(0.42, 0.40, 0.36), 0.65)
	# Eastern dirt alternate
	_box(Vector3(3.5, 0.1, 70), Vector3(18, 0.05, -20), Color(0.48, 0.38, 0.26), 0.95)


func _build_river_and_bridge() -> void:
	# River band — visual only so crossing remains walkable after a plan
	var river := _box(Vector3(120, 0.5, 14), Vector3(0, -0.35, -28), Color(0.18, 0.36, 0.52), 0.15, false)
	river.material_override = _water_mat(Color(0.18, 0.36, 0.52, 0.85))
	# Intact abutments
	_box(Vector3(8, 1.6, 3), Vector3(0, 0.7, -21), Color(0.52, 0.50, 0.46))
	_box(Vector3(8, 1.6, 3), Vector3(0, 0.7, -35), Color(0.52, 0.50, 0.46))
	# Destroyed span pieces
	_box(Vector3(3.5, 0.6, 4), Vector3(-2.5, 0.9, -25), Color(0.48, 0.45, 0.40))
	_box(Vector3(3.2, 0.55, 3.5), Vector3(2.8, 0.7, -31), Color(0.48, 0.45, 0.40))
	_box(Vector3(2.0, 0.5, 2.5), Vector3(-1.0, -0.05, -28), Color(0.42, 0.38, 0.34))
	_box(Vector3(1.5, 0.4, 1.8), Vector3(1.5, -0.1, -27), Color(0.40, 0.36, 0.32))
	# Smoke / fire marker (emissive block)
	var flame := _box(Vector3(0.8, 1.2, 0.8), Vector3(0.5, 1.4, -28), Color(0.95, 0.45, 0.15), 0.4, false)
	var mat := flame.material_override as StandardMaterial3D
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.35, 0.05)
	mat.emission_energy_multiplier = 2.0
	# Hidden ford walkway east of bridge
	_box(Vector3(4, 0.12, 16), Vector3(12, 0.06, -28), Color(0.40, 0.36, 0.28), 0.9)


func _build_village() -> void:
	_box(Vector3(5, 2.6, 4.5), Vector3(16, 1.3, -18), Color(0.55, 0.48, 0.38))
	_box(Vector3(5.4, 0.7, 4.9), Vector3(16, 2.95, -18), Color(0.40, 0.28, 0.20))
	_box(Vector3(4, 2.3, 4), Vector3(22, 1.15, -22), Color(0.52, 0.46, 0.36))
	_box(Vector3(4.4, 0.65, 4.4), Vector3(22, 2.6, -22), Color(0.38, 0.26, 0.18))
	_box(Vector3(3.5, 2.2, 3.5), Vector3(14, 1.1, -14), Color(0.50, 0.44, 0.34))


func _build_highwatch() -> void:
	# Castle on hill
	_box(Vector3(22, 6, 18), Vector3(0, 2.5, -78), Color(0.48, 0.50, 0.46), 0.9)
	_box(Vector3(14, 8, 12), Vector3(0, 7.5, -78), Color(0.55, 0.55, 0.52))
	_box(Vector3(3, 10, 3), Vector3(-5, 10, -74), Color(0.52, 0.52, 0.50))
	_box(Vector3(3, 10, 3), Vector3(5, 10, -74), Color(0.52, 0.52, 0.50))
	_box(Vector3(3, 11, 3), Vector3(-5, 10.5, -82), Color(0.52, 0.52, 0.50))
	_box(Vector3(3, 11, 3), Vector3(5, 10.5, -82), Color(0.52, 0.52, 0.50))
	# Red banners
	_box(Vector3(0.15, 2.5, 0.8), Vector3(-5, 16, -74), Color(0.75, 0.18, 0.15))
	_box(Vector3(0.15, 2.5, 0.8), Vector3(5, 16, -74), Color(0.75, 0.18, 0.15))


func _build_scrub() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for i in range(55):
		var x := rng.randf_range(-55.0, 55.0)
		var z := rng.randf_range(-90.0, 40.0)
		if absf(x) < 8.0 and z > -70.0:
			continue
		var h := rng.randf_range(0.5, 2.2)
		_box(Vector3(0.4, h, 0.4), Vector3(x, h * 0.5, z), Color(0.22, 0.35, 0.18), 0.95)


func set_bridge_repaired(repaired: bool) -> void:
	if not repaired:
		return
	_box(Vector3(7, 0.5, 12), Vector3(0, 1.1, -28), Color(0.48, 0.42, 0.32), 0.8)
