extends CharacterBody3D

@export var max_health: int = 3
@export var recoil_distance: float = 0.35

var health: int
var defeated: bool = false
var base_scale: Vector3
var base_rotation: Vector3
var original_materials: Dictionary = {}


func _ready() -> void:
	health = max_health
	base_scale = scale
	base_rotation = rotation_degrees
	add_to_group("enemies")
	_cache_mesh_materials(self)


func take_hit(damage: int, hit_direction: Vector3) -> bool:
	if defeated:
		return true

	health -= damage
	print("%s hit by Veinmore. HP: %d" % [name, max(health, 0)])

	if health <= 0:
		_defeat(hit_direction)
		return true
	else:
		_flash_and_recoil(hit_direction)
		return false


func _flash_and_recoil(hit_direction: Vector3) -> void:
	var recoil := hit_direction.normalized() * recoil_distance * 1.55
	recoil.y = 0.0

	_apply_flash(true)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", global_position + recoil, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", base_rotation + Vector3(-11.0, 0.0, signf(recoil.x) * 15.0), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector3(base_scale.x * 1.2, base_scale.y * 0.88, base_scale.z * 1.18), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", base_scale, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", base_rotation, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.16).timeout
	_apply_flash(false)


func _defeat(hit_direction: Vector3) -> void:
	defeated = true
	collision_layer = 0
	collision_mask = 0

	var recoil := hit_direction.normalized() * recoil_distance * 1.7
	recoil.y = 0.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", global_position + recoil + Vector3.DOWN * 0.55, 0.42).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "rotation_degrees", rotation_degrees + Vector3(88.0, 0.0, signf(recoil.x) * 42.0), 0.42)
	tween.tween_property(self, "scale", Vector3(base_scale.x * 1.18, base_scale.y * 0.06, base_scale.z * 1.18), 0.42)
	await tween.finished
	queue_free()


func _cache_mesh_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh := node as MeshInstance3D
		original_materials[mesh] = mesh.material_override

	for child in node.get_children():
		_cache_mesh_materials(child)


func _apply_flash(enabled: bool) -> void:
	for mesh in original_materials.keys():
		if enabled:
			var flash := StandardMaterial3D.new()
			flash.albedo_color = Color(1.0, 0.12, 0.08, 1.0)
			flash.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mesh.material_override = flash
		else:
			mesh.material_override = original_materials[mesh]
