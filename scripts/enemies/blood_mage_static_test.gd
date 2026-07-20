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

var current_health: int
var defeated: bool = false
var knockback_tween: Tween
var feedback_tween: Tween
var player: Node3D
var grounded_y: float
var base_scale: Vector3
var warned_missing_player: bool = false


func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	grounded_y = global_position.y
	base_scale = scale
	_find_player()


func _physics_process(delta: float) -> void:
	if defeated:
		velocity = Vector3.ZERO
		return

	if player == null:
		_find_player()
		if player == null:
			velocity = Vector3.ZERO
			if not warned_missing_player:
				print("%s movement failed: player not found." % debug_name)
				warned_missing_player = true
			return

	var to_player := player.global_position - global_position
	to_player.y = 0.0
	var distance := to_player.length()
	if distance <= stop_distance:
		velocity = Vector3.ZERO
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
	defeated = true
	velocity = Vector3.ZERO
	collision_layer = 0
	collision_mask = 0

	if knockback_tween != null and knockback_tween.is_running():
		knockback_tween.kill()
	if feedback_tween != null and feedback_tween.is_running():
		feedback_tween.kill()

	print("%s eliminated" % debug_name)
	var death_tween := create_tween()
	death_tween.tween_property(self, "scale", Vector3(base_scale.x * 0.75, base_scale.y * 0.05, base_scale.z * 0.75), death_free_delay).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
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
