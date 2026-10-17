extends CharacterBody3D

@export var max_health: int = 3
@export var recoil_distance: float = 0.35
@export var respawn_delay: float = 1.5

var health: int
var defeated: bool = false
var base_scale: Vector3
var starting_transform: Transform3D
var starting_visible: bool
var starting_collision_layer: int
var starting_collision_mask: int
var original_materials: Dictionary = {}

@onready var skeleton_model := $SkeletonModel as Node3D

var skeleton_model_base_transform: Transform3D


func _ready() -> void:
	health = max_health
	starting_transform = transform
	starting_visible = visible
	starting_collision_layer = collision_layer
	starting_collision_mask = collision_mask
	base_scale = scale
	skeleton_model_base_transform = skeleton_model.transform
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
	var visual_base_scale := skeleton_model_base_transform.basis.get_scale()
	var visual_base_rotation := skeleton_model_base_transform.basis.get_euler()

	_apply_flash(true)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", global_position + recoil, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(skeleton_model, "rotation", visual_base_rotation + Vector3(deg_to_rad(-11.0), 0.0, deg_to_rad(signf(recoil.x) * 15.0)), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(skeleton_model, "scale", Vector3(visual_base_scale.x * 1.2, visual_base_scale.y * 0.88, visual_base_scale.z * 1.18), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain()
	tween.set_parallel(true)
	tween.tween_property(skeleton_model, "scale", visual_base_scale, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(skeleton_model, "rotation", visual_base_rotation, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(0.16).timeout
	_apply_flash(false)


func _defeat(hit_direction: Vector3) -> void:
	defeated = true
	collision_layer = 0
	collision_mask = 0

	var recoil := hit_direction.normalized() * recoil_distance * 1.7
	recoil.y = 0.0
	var visual_base_scale := skeleton_model_base_transform.basis.get_scale()

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", global_position + recoil + Vector3.DOWN * 0.55, 0.42).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(skeleton_model, "rotation", skeleton_model.rotation + Vector3(deg_to_rad(88.0), 0.0, deg_to_rad(signf(recoil.x) * 42.0)), 0.42)
	tween.tween_property(skeleton_model, "scale", Vector3(visual_base_scale.x * 1.18, visual_base_scale.y * 0.06, visual_base_scale.z * 1.18), 0.42)
	await tween.finished
	visible = false
	_apply_flash(false)
	await get_tree().create_timer(respawn_delay).timeout
	_respawn()


func _respawn() -> void:
	transform = starting_transform
	skeleton_model.transform = skeleton_model_base_transform
	health = max_health
	velocity = Vector3.ZERO
	scale = base_scale
	_apply_flash(false)
	visible = starting_visible
	collision_layer = starting_collision_layer
	collision_mask = starting_collision_mask
	defeated = false


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
