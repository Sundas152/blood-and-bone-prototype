extends Camera3D

@export var target_path: NodePath
@export var follow_speed: float = 6.0
@export var camera_height: float = 4.6
@export var camera_distance: float = 6.8
@export var side_offset: float = 1.4
@export var look_at_height: float = 1.1
@export var rotation_follow_speed: float = 7.0
@export var bob_amount: float = 0.035
@export var bob_speed: float = 7.0
@export var micro_jitter_amount: float = 0.006
@export var micro_jitter_speed: float = 9.0
@export var shake_decay: float = 7.5

var target: Node3D
var follow_yaw: float = 0.0
var bob_time: float = 0.0
var jitter_time: float = 0.0
var jitter_offset: Vector3 = Vector3.ZERO
var shake_strength: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.seed = 2501
	_find_target()

	if target != null:
		follow_yaw = target.global_rotation.y
		global_position = _get_desired_position()
		_look_at_target()


func _process(delta: float) -> void:
	if target == null:
		_find_target()

	if target == null:
		return

	# Follow player facing so the camera stays behind them regardless of direction.
	follow_yaw = lerp_angle(follow_yaw, target.global_rotation.y, 1.0 - exp(-rotation_follow_speed * delta))
	_update_bob(delta)
	_update_micro_jitter(delta)
	_update_shake(delta)

	var desired_position := _get_desired_position()
	var follow_weight := 1.0 - exp(-follow_speed * delta)
	global_position = global_position.lerp(desired_position, follow_weight)
	global_position += jitter_offset + _get_shake_offset()
	_look_at_target()


func _get_desired_position() -> Vector3:
	var facing_basis := Basis(Vector3.UP, follow_yaw)
	var behind_direction := facing_basis.z.normalized()
	var side_direction := facing_basis.x.normalized()
	var bob := sin(bob_time) * bob_amount

	return target.global_position \
		+ behind_direction * camera_distance \
		+ side_direction * side_offset \
		+ Vector3.UP * (camera_height + bob)


func _look_at_target() -> void:
	var look_position := target.global_position + Vector3.UP * look_at_height
	look_at(look_position, Vector3.UP)


func _find_target() -> void:
	if target_path != NodePath():
		target = get_node_or_null(target_path) as Node3D


func add_shake(amount: float, duration: float) -> void:
	# Combat uses this for tiny console-action feedback, not a full screen shake system.
	shake_strength = maxf(shake_strength, amount)
	shake_duration = maxf(shake_duration, duration)
	shake_timer = shake_duration


func _update_bob(delta: float) -> void:
	var planar_speed := 0.0
	if target is CharacterBody3D:
		var body := target as CharacterBody3D
		planar_speed = Vector2(body.velocity.x, body.velocity.z).length()

	if planar_speed > 0.08:
		bob_time += delta * bob_speed
	else:
		bob_time = lerpf(bob_time, 0.0, 1.0 - exp(-4.0 * delta))


func _update_micro_jitter(delta: float) -> void:
	jitter_time += delta
	var step_time := 1.0 / maxf(micro_jitter_speed, 0.01)
	if jitter_time < step_time:
		return

	jitter_time = 0.0
	jitter_offset = Vector3(
		rng.randf_range(-micro_jitter_amount, micro_jitter_amount),
		rng.randf_range(-micro_jitter_amount, micro_jitter_amount),
		0.0
	)


func _update_shake(delta: float) -> void:
	if shake_timer <= 0.0:
		shake_strength = lerpf(shake_strength, 0.0, 1.0 - exp(-shake_decay * delta))
		return

	shake_timer = maxf(shake_timer - delta, 0.0)
	if shake_duration > 0.0:
		var remaining := shake_timer / shake_duration
		shake_strength = lerpf(shake_strength, shake_strength * remaining, 1.0 - exp(-shake_decay * delta))


func _get_shake_offset() -> Vector3:
	if shake_strength <= 0.001:
		return Vector3.ZERO

	return Vector3(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength),
		0.0
	)
