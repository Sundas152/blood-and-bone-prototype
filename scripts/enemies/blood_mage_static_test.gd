extends CharacterBody3D

@export var debug_name: String = "Blood Mage"
@export var max_health: int = 3
@export var recoil_distance: float = 0.35
@export var player_path: NodePath = NodePath("../Player")
@export var move_speed: float = 0.85
@export var stop_distance: float = 1.35
@export var turn_speed: float = 7.0
@export var hit_pulse_scale: float = 1.08
@export var death_free_delay: float = 0.35
@export var attack_range: float = 1.55
@export var attack_damage: int = 1
@export var anticipation_duration: float = 0.55
@export var active_duration: float = 0.12
@export var recovery_duration: float = 0.45
@export var attack_cooldown_duration: float = 0.75

enum AttackPhase {
	IDLE,
	ANTICIPATION,
	ACTIVE,
	RECOVERY,
}

var current_health: int
var defeated: bool = false
var knockback_tween: Tween
var feedback_tween: Tween
var player: Node3D
var grounded_y: float
var base_scale: Vector3
var warned_missing_player: bool = false
var attack_phase: AttackPhase = AttackPhase.IDLE
var attack_sequence_token: int = 0
var attack_hit_player: bool = false
var attack_cooldown_remaining: float = 0.0
var attack_visual_tween: Tween
var blood_mage_model_base_transform: Transform3D
var blood_mage_mesh_base_overlay: Material
var telegraph_overlay: StandardMaterial3D

@onready var blood_mage_model := get_node_or_null("BloodMageModel") as Node3D
@onready var blood_mage_mesh := get_node_or_null("BloodMageModel/blood_mage_model") as MeshInstance3D


func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	grounded_y = global_position.y
	base_scale = scale
	_cache_attack_visual_state()
	_find_player()


func _physics_process(delta: float) -> void:
	if defeated:
		velocity = Vector3.ZERO
		return

	if player != null and not is_instance_valid(player):
		player = null
		_cancel_attack()

	if player == null:
		_find_player()
		if player == null:
			_cancel_attack()
			velocity = Vector3.ZERO
			if not warned_missing_player:
				print("%s movement failed: player not found." % debug_name)
				warned_missing_player = true
			return

	var to_player := player.global_position - global_position
	to_player.y = 0.0
	var distance := to_player.length()
	if attack_phase != AttackPhase.IDLE:
		velocity = Vector3.ZERO
		if to_player.length_squared() > 0.0001:
			_face_direction(to_player.normalized(), delta)
		if attack_phase == AttackPhase.ACTIVE:
			_try_damage_player()
		return

	attack_cooldown_remaining = maxf(attack_cooldown_remaining - delta, 0.0)
	if distance <= stop_distance:
		velocity = Vector3.ZERO
		if _can_start_attack():
			_start_attack()
		return

	var direction := to_player.normalized()
	_face_direction(direction, delta)
	velocity.x = direction.x * move_speed
	velocity.y = 0.0
	velocity.z = direction.z * move_speed
	move_and_slide()
	global_position.y = grounded_y


func take_damage(amount: int) -> bool:
	if defeated:
		return true

	current_health = max(current_health - amount, 0)
	print("%s took %d damage" % [debug_name, amount])
	print("%s HP: %d/%d" % [debug_name, current_health, max_health])

	if current_health <= 0:
		_eliminate()
		return true

	return false


func take_hit(damage: int, hit_direction: Vector3) -> bool:
	_cancel_attack(true)
	print("%s hit" % debug_name)
	var was_defeated := take_damage(damage)
	if not was_defeated:
		_apply_hit_feedback(hit_direction)
	return was_defeated


func _apply_hit_feedback(hit_direction: Vector3) -> void:
	var recoil := hit_direction.normalized() * recoil_distance
	recoil.y = 0.0

	if knockback_tween != null and knockback_tween.is_running():
		knockback_tween.kill()
	if feedback_tween != null and feedback_tween.is_running():
		feedback_tween.kill()

	scale = base_scale

	knockback_tween = create_tween()
	knockback_tween.tween_property(self, "global_position", global_position + recoil, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	feedback_tween = create_tween()
	feedback_tween.tween_property(self, "scale", base_scale * hit_pulse_scale, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	feedback_tween.tween_property(self, "scale", base_scale, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _eliminate() -> void:
	_cancel_attack()
	defeated = true
	velocity = Vector3.ZERO
	collision_layer = 0
	collision_mask = 0

	if knockback_tween != null and knockback_tween.is_running():
		knockback_tween.kill()
	if feedback_tween != null and feedback_tween.is_running():
		feedback_tween.kill()

	print("%s eliminated" % debug_name)
	var death_transform := blood_mage_model_base_transform.scaled_local(Vector3(0.75, 0.05, 0.75))
	var death_tween := create_tween()
	death_tween.tween_property(blood_mage_model, "transform", death_transform, death_free_delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	death_tween.tween_callback(queue_free)


func _find_player() -> void:
	player = get_node_or_null(player_path) as Node3D
	if player != null:
		warned_missing_player = false
		return

	var scene := get_tree().current_scene
	if scene != null:
		player = scene.find_child("Player", true, false) as Node3D
		if player != null:
			warned_missing_player = false


func _face_direction(direction: Vector3, delta: float) -> void:
	if direction.length_squared() <= 0.0001:
		return

	var target_yaw := atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, 1.0 - exp(-turn_speed * delta))


func _cache_attack_visual_state() -> void:
	if blood_mage_model == null or blood_mage_mesh == null:
		push_warning("%s attack disabled: model or mesh not found." % debug_name)
		return

	blood_mage_model_base_transform = blood_mage_model.transform
	blood_mage_mesh_base_overlay = blood_mage_mesh.material_overlay
	telegraph_overlay = StandardMaterial3D.new()
	telegraph_overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	telegraph_overlay.albedo_color = Color(0.92, 0.82, 0.56, 0.58)
	telegraph_overlay.emission_enabled = true
	telegraph_overlay.emission = Color(0.9, 0.72, 0.36, 1.0)
	telegraph_overlay.emission_energy_multiplier = 0.75


func _can_start_attack() -> bool:
	return attack_phase == AttackPhase.IDLE \
		and attack_cooldown_remaining <= 0.0 \
		and not defeated \
		and visible \
		and process_mode != Node.PROCESS_MODE_DISABLED \
		and player != null \
		and is_instance_valid(player) \
		and player.has_method("take_hit") \
		and blood_mage_model != null \
		and blood_mage_mesh != null \
		and not _is_recoiling()


func _is_recoiling() -> bool:
	return (knockback_tween != null and knockback_tween.is_running()) \
		or (feedback_tween != null and feedback_tween.is_running())


func _start_attack() -> void:
	if not _can_start_attack():
		return

	attack_sequence_token += 1
	var sequence_token := attack_sequence_token
	attack_phase = AttackPhase.ANTICIPATION
	attack_hit_player = false
	velocity = Vector3.ZERO
	blood_mage_mesh.material_overlay = telegraph_overlay

	var anticipation_transform := blood_mage_model_base_transform.translated_local(Vector3(0.0, 0.12, 0.18))
	attack_visual_tween = create_tween()
	attack_visual_tween.tween_property(blood_mage_model, "transform", anticipation_transform, anticipation_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(anticipation_duration).timeout
	if not _attack_remains_valid(sequence_token):
		_cancel_if_current(sequence_token)
		return

	attack_phase = AttackPhase.ACTIVE
	var active_transform := blood_mage_model_base_transform.translated_local(Vector3(0.0, 0.02, -0.3))
	attack_visual_tween = create_tween()
	attack_visual_tween.tween_property(blood_mage_model, "transform", active_transform, active_duration * 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(active_duration).timeout
	if not _attack_remains_valid(sequence_token):
		_cancel_if_current(sequence_token)
		return

	attack_phase = AttackPhase.RECOVERY
	blood_mage_mesh.material_overlay = blood_mage_mesh_base_overlay
	attack_visual_tween = create_tween()
	attack_visual_tween.tween_property(blood_mage_model, "transform", blood_mage_model_base_transform, recovery_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(recovery_duration).timeout
	if not _attack_remains_valid(sequence_token):
		_cancel_if_current(sequence_token)
		return

	_restore_attack_visuals()
	attack_phase = AttackPhase.IDLE
	attack_cooldown_remaining = attack_cooldown_duration


func _attack_remains_valid(sequence_token: int) -> bool:
	return attack_sequence_token == sequence_token \
		and attack_phase != AttackPhase.IDLE \
		and not defeated \
		and visible \
		and process_mode != Node.PROCESS_MODE_DISABLED \
		and player != null \
		and is_instance_valid(player) \
		and not _is_recoiling()


func _try_damage_player() -> void:
	if attack_hit_player or player == null or not is_instance_valid(player):
		return
	if not player.has_method("take_hit"):
		_cancel_attack()
		return

	var to_player := player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() > attack_range:
		return

	attack_hit_player = true
	player.take_hit(attack_damage, to_player.normalized())


func _cancel_attack(start_cooldown: bool = false) -> void:
	if attack_phase == AttackPhase.IDLE:
		return

	attack_sequence_token += 1
	attack_phase = AttackPhase.IDLE
	attack_hit_player = false
	velocity = Vector3.ZERO
	if start_cooldown:
		attack_cooldown_remaining = attack_cooldown_duration
	_restore_attack_visuals()


func _cancel_if_current(sequence_token: int) -> void:
	if attack_sequence_token == sequence_token:
		_cancel_attack()


func _restore_attack_visuals() -> void:
	if attack_visual_tween != null and attack_visual_tween.is_running():
		attack_visual_tween.kill()
	attack_visual_tween = null
	if blood_mage_model != null:
		blood_mage_model.transform = blood_mage_model_base_transform
	if blood_mage_mesh != null:
		blood_mage_mesh.material_overlay = blood_mage_mesh_base_overlay
