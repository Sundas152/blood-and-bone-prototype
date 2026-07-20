extends CharacterBody3D

@export var speed: float = 5.0
@export var acceleration: float = 16.0
@export var friction: float = 18.0
@export var rotation_speed: float = 10.5
@export var camera_path: NodePath
@export var walk_animation_speed: float = 7.2
@export var walk_swing_amount: float = 0.38
@export var walk_bob_amount: float = 0.055
@export var summon_duration: float = 2.8
@export var slash_damage: int = 1
@export var input_deadzone: float = 0.08

var last_move_direction: Vector3 = Vector3.FORWARD
var follow_camera: Camera3D
var walk_phase: float = 0.0
var idle_phase: float = 0.0
var veinmore_active: bool = false
var is_summoning: bool = false
var is_attacking: bool = false
var is_dismissing: bool = false
var movement_locked: bool = false
var damaged_this_slash: Array[Node] = []
var model_base_position: Vector3 = Vector3.ZERO
var model_base_rotation: Vector3 = Vector3.ZERO
var left_arm_base_scale: Vector3 = Vector3.ONE
var right_arm_base_scale: Vector3 = Vector3.ONE
var left_arm_base_rotation: Vector3 = Vector3.ZERO
var right_arm_base_rotation: Vector3 = Vector3.ZERO
var left_leg_base_rotation: Vector3 = Vector3.ZERO
var right_leg_base_rotation: Vector3 = Vector3.ZERO
var right_arm_combat_rotation: Vector3 = Vector3.ZERO
var left_arm_combat_rotation: Vector3 = Vector3.ZERO
var weapon_attachment_ready_rotation: Vector3 = Vector3.ZERO
var left_shoe_base_position: Vector3 = Vector3.ZERO
var right_shoe_base_position: Vector3 = Vector3.ZERO
var weapon_attachment_base_rotation: Vector3 = Vector3.ZERO
var veinmore_grip_root_base_position: Vector3 = Vector3.ZERO
var veinmore_grip_root_base_rotation: Vector3 = Vector3.ZERO
var veinmore_swing_pivot_base_rotation: Vector3 = Vector3.ZERO
var veinmore_base_position: Vector3 = Vector3.ZERO
var veinmore_base_rotation: Vector3 = Vector3.ZERO
var veinmore_base_scale: Vector3 = Vector3.ONE
var veinmore_ready_scale: Vector3 = Vector3.ONE
var extraction_strand_base_position: Vector3 = Vector3.ZERO
var extraction_strand_base_rotation: Vector3 = Vector3.ZERO
var extraction_strand_base_scale: Vector3 = Vector3.ONE
var veinmore_trail_base_position: Vector3 = Vector3.ZERO
var veinmore_trail_base_rotation: Vector3 = Vector3.ZERO
var veinmore_trail_base_scale: Vector3 = Vector3.ONE
var veinmore_handle_base_position: Vector3 = Vector3.ZERO
var veinmore_handle_base_scale: Vector3 = Vector3.ONE
var right_grip_point_base_position: Vector3 = Vector3.ZERO
var right_grip_point_base_scale: Vector3 = Vector3.ONE
var left_grip_point_base_position: Vector3 = Vector3.ZERO
var left_grip_point_base_scale: Vector3 = Vector3.ONE
var hips_pivot_base_position: Vector3 = Vector3.ZERO
var hips_pivot_base_rotation: Vector3 = Vector3.ZERO
var combat_torso_base_position: Vector3 = Vector3.ZERO
var combat_torso_base_rotation: Vector3 = Vector3.ZERO
var shoulder_pivot_base_rotation: Vector3 = Vector3.ZERO
var right_combat_arm_base_position: Vector3 = Vector3.ZERO
var right_combat_arm_base_rotation: Vector3 = Vector3.ZERO
var left_combat_arm_base_position: Vector3 = Vector3.ZERO
var left_combat_arm_base_rotation: Vector3 = Vector3.ZERO
var right_forearm_base_rotation: Vector3 = Vector3.ZERO
var left_forearm_base_rotation: Vector3 = Vector3.ZERO
var right_grip_hand_base_position: Vector3 = Vector3.ZERO
var left_grip_hand_base_position: Vector3 = Vector3.ZERO
var right_combat_arm_base_scale: Vector3 = Vector3.ONE
var left_combat_arm_base_scale: Vector3 = Vector3.ONE
var right_grip_hand_base_scale: Vector3 = Vector3.ONE
var left_grip_hand_base_scale: Vector3 = Vector3.ONE
var arm_transition_vessel_base_scales: Dictionary = {}
var fallback_attack_was_pressed: bool = false
var fallback_dismiss_was_pressed: bool = false

@onready var model := get_node_or_null("Model") as Node3D
@onready var left_arm := get_node_or_null("Model/LeftArm") as Node3D
@onready var right_arm := get_node_or_null("Model/RightArm") as Node3D
@onready var left_leg := get_node_or_null("Model/VisualRoot/HipsPivot/LeftLegPivot") as Node3D
@onready var right_leg := get_node_or_null("Model/VisualRoot/HipsPivot/RightLegPivot") as Node3D
@onready var left_shoe := get_node_or_null("Model/VisualRoot/HipsPivot/LeftLegPivot/LeftFoot") as Node3D
@onready var right_shoe := get_node_or_null("Model/VisualRoot/HipsPivot/RightLegPivot/RightFoot") as Node3D
@onready var weapon_attachment := get_node_or_null("Model/WeaponAttachment") as Node3D
@onready var visual_root := get_node_or_null("Model/VisualRoot") as Node3D
@onready var hips_pivot := get_node_or_null("Model/VisualRoot/HipsPivot") as Node3D
@onready var torso_pivot := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot") as Node3D
@onready var shoulder_pivot := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot") as Node3D
@onready var right_arm_pivot := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/RightArmPivot") as Node3D
@onready var left_arm_pivot := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/LeftArmPivot") as Node3D
@onready var right_forearm_pivot := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/RightArmPivot/RightForearmPivot") as Node3D
@onready var left_forearm_pivot := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/LeftArmPivot/LeftForearmPivot") as Node3D
@onready var combat_torso_pivot := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot") as Node3D
@onready var right_combat_arm := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/RightArmPivot") as Node3D
@onready var left_combat_arm := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/LeftArmPivot") as Node3D
@onready var right_grip_hand := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/RightArmPivot/RightForearmPivot/RightGripPoint") as MeshInstance3D
@onready var left_grip_hand := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/LeftArmPivot/LeftForearmPivot/LeftGripPoint") as MeshInstance3D
@onready var veinmore_grip_root := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/VeinmoreGripRoot") as Node3D
@onready var veinmore_swing_pivot := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/VeinmoreGripRoot/VeinmoreSwingPivot") as Node3D
@onready var veinmore := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/VeinmoreGripRoot/VeinmoreSwingPivot/Veinmore") as Node3D
@onready var extraction_strand := get_node_or_null("Model/WeaponAttachment/ExtractionStrand") as Node3D
@onready var veinmore_trail := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/VeinmoreGripRoot/VeinmoreSwingPivot/VeinmoreTrail") as MeshInstance3D
@onready var veinmore_handle_point := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/VeinmoreGripRoot/VeinmoreSwingPivot/VeinmoreHandlePoint") as MeshInstance3D
@onready var right_grip_point := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/RightArmPivot/RightForearmPivot/RightGripPoint") as MeshInstance3D
@onready var left_grip_point := get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/LeftArmPivot/LeftForearmPivot/LeftGripPoint") as MeshInstance3D
@onready var veinmore_hitbox := get_node_or_null("VeinmoreHitbox") as Area3D
@onready var arm_transition_vessels := get_node_or_null("Model/ArmTransitionVessels") as Node3D


func _ready() -> void:
	if camera_path != NodePath():
		follow_camera = get_node_or_null(camera_path) as Camera3D
	_cache_animation_pose()
	_prepare_veinmore()


func _physics_process(delta: float) -> void:
	if _is_attack_just_pressed():
		_handle_attack_input()
	if _is_dismiss_just_pressed():
		_handle_dismiss_input()

	# Convert 2D input into camera-relative movement on the X/Z plane.
	var input_direction := _get_movement_input()
	var move_direction := _get_camera_relative_direction(input_direction)

	if movement_locked:
		_apply_planar_velocity(Vector3.ZERO, friction, delta)
	elif move_direction.length_squared() > input_deadzone * input_deadzone:
		move_direction = move_direction.normalized()
		last_move_direction = move_direction

		# Accelerate with exponential smoothing so movement feels weighty instead of grid-snapped.
		_apply_planar_velocity(move_direction * speed, acceleration, delta)
		_face_direction(move_direction, delta)
	else:
		# Slow to a stop when no movement input is held.
		_apply_planar_velocity(Vector3.ZERO, friction, delta)

	# This prototype has no jumping or vertical movement yet.
	velocity.y = 0.0
	move_and_slide()
	_check_veinmore_hits()
	_update_walk_animation(delta)


func _get_movement_input() -> Vector2:
	if _has_movement_actions():
		return Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var input_direction := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		input_direction.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		input_direction.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		input_direction.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		input_direction.y += 1.0

	return input_direction.normalized()


func _has_movement_actions() -> bool:
	return InputMap.has_action("move_left") \
		and InputMap.has_action("move_right") \
		and InputMap.has_action("move_up") \
		and InputMap.has_action("move_down")


func _is_attack_just_pressed() -> bool:
	if InputMap.has_action("attack") and Input.is_action_just_pressed("attack"):
		return true
	if InputMap.has_action("ui_accept") and Input.is_action_just_pressed("ui_accept"):
		return true

	var is_pressed := Input.is_physical_key_pressed(KEY_J) or Input.is_physical_key_pressed(KEY_SPACE)
	var just_pressed := is_pressed and not fallback_attack_was_pressed
	fallback_attack_was_pressed = is_pressed
	return just_pressed


func _is_dismiss_just_pressed() -> bool:
	if InputMap.has_action("dismiss_weapon") and Input.is_action_just_pressed("dismiss_weapon"):
		return true
	if InputMap.has_action("ui_cancel") and Input.is_action_just_pressed("ui_cancel"):
		return true

	var is_pressed := Input.is_physical_key_pressed(KEY_K) or Input.is_physical_key_pressed(KEY_ESCAPE)
	var just_pressed := is_pressed and not fallback_dismiss_was_pressed
	fallback_dismiss_was_pressed = is_pressed
	return just_pressed


func _face_direction(direction: Vector3, delta: float) -> void:
	# The player model faces local -Z, so rotate the body toward the X/Z movement direction.
	var target_yaw := atan2(-direction.x, -direction.z)
	var planar_speed := Vector2(velocity.x, velocity.z).length()
	var turn_intent := clampf(planar_speed / maxf(speed, 0.01), 0.25, 1.0)
	var turn_rate := lerpf(rotation_speed * 0.62, rotation_speed, turn_intent)
	rotation.y = lerp_angle(rotation.y, target_yaw, 1.0 - exp(-turn_rate * delta))


func _apply_planar_velocity(target_velocity: Vector3, rate: float, delta: float) -> void:
	var weight := 1.0 - exp(-rate * delta)
	velocity.x = lerpf(velocity.x, target_velocity.x, weight)
	velocity.z = lerpf(velocity.z, target_velocity.z, weight)


func _get_camera_relative_direction(input_direction: Vector2) -> Vector3:
	if input_direction == Vector2.ZERO:
		return Vector3.ZERO

	var camera := follow_camera
	if camera == null:
		camera = get_viewport().get_camera_3d()

	if camera == null:
		return Vector3(input_direction.x, 0.0, input_direction.y).normalized()

	# Project the camera's forward and right vectors onto the floor.
	var camera_forward := -camera.global_transform.basis.z
	camera_forward.y = 0.0
	camera_forward = camera_forward.normalized()

	var camera_right := camera.global_transform.basis.x
	camera_right.y = 0.0
	camera_right = camera_right.normalized()

	# Input.get_vector returns W/up as negative Y, so invert it for forward movement.
	return (camera_right * input_direction.x + camera_forward * -input_direction.y).normalized()


func _cache_animation_pose() -> void:
	if model != null:
		model_base_position = model.position
		model_base_rotation = model.rotation
	if left_arm != null:
		left_arm_base_rotation = left_arm.rotation
		left_arm_base_scale = left_arm.scale
		left_arm_combat_rotation = left_arm_base_rotation + Vector3(-1.02, -0.62, -0.52)
	if right_arm != null:
		right_arm_base_rotation = right_arm.rotation
		right_arm_base_scale = right_arm.scale
		right_arm_combat_rotation = right_arm_base_rotation + Vector3(-1.08, 0.34, 0.6)
	if left_leg != null:
		left_leg_base_rotation = left_leg.rotation
	if right_leg != null:
		right_leg_base_rotation = right_leg.rotation
	if left_shoe != null:
		left_shoe_base_position = left_shoe.position
	if right_shoe != null:
		right_shoe_base_position = right_shoe.position
	if weapon_attachment != null:
		weapon_attachment_base_rotation = weapon_attachment.rotation_degrees
		weapon_attachment_ready_rotation = weapon_attachment_base_rotation
	if veinmore_grip_root != null:
		veinmore_grip_root_base_position = veinmore_grip_root.position
		veinmore_grip_root_base_rotation = veinmore_grip_root.rotation_degrees
	if veinmore_swing_pivot != null:
		veinmore_swing_pivot_base_rotation = veinmore_swing_pivot.rotation_degrees
	if veinmore != null:
		veinmore_base_position = veinmore.position
		veinmore_base_rotation = veinmore.rotation_degrees
		veinmore_base_scale = veinmore.scale
	if extraction_strand != null:
		extraction_strand_base_position = extraction_strand.position
		extraction_strand_base_rotation = extraction_strand.rotation_degrees
		extraction_strand_base_scale = extraction_strand.scale
	if veinmore_trail != null:
		veinmore_trail_base_position = veinmore_trail.position
		veinmore_trail_base_rotation = veinmore_trail.rotation_degrees
		veinmore_trail_base_scale = veinmore_trail.scale
	if veinmore_handle_point != null:
		veinmore_handle_base_position = veinmore_handle_point.position
		veinmore_handle_base_scale = veinmore_handle_point.scale
	if right_grip_point != null:
		right_grip_point_base_position = right_grip_point.position
		right_grip_point_base_scale = right_grip_point.scale
	if left_grip_point != null:
		left_grip_point_base_position = left_grip_point.position
		left_grip_point_base_scale = left_grip_point.scale
	if hips_pivot != null:
		hips_pivot_base_position = hips_pivot.position
		hips_pivot_base_rotation = hips_pivot.rotation_degrees
	if combat_torso_pivot != null:
		combat_torso_base_position = combat_torso_pivot.position
		combat_torso_base_rotation = combat_torso_pivot.rotation_degrees
	if shoulder_pivot != null:
		shoulder_pivot_base_rotation = shoulder_pivot.rotation_degrees
	if right_combat_arm != null:
		right_combat_arm_base_position = right_combat_arm.position
		right_combat_arm_base_rotation = right_combat_arm.rotation_degrees
		right_combat_arm_base_scale = right_combat_arm.scale
	if left_combat_arm != null:
		left_combat_arm_base_position = left_combat_arm.position
		left_combat_arm_base_rotation = left_combat_arm.rotation_degrees
		left_combat_arm_base_scale = left_combat_arm.scale
	if right_forearm_pivot != null:
		right_forearm_base_rotation = right_forearm_pivot.rotation_degrees
	if left_forearm_pivot != null:
		left_forearm_base_rotation = left_forearm_pivot.rotation_degrees
	if right_grip_hand != null:
		right_grip_hand_base_position = right_grip_hand.position
		right_grip_hand_base_scale = right_grip_hand.scale
	if left_grip_hand != null:
		left_grip_hand_base_position = left_grip_hand.position
		left_grip_hand_base_scale = left_grip_hand.scale
	if arm_transition_vessels != null:
		for vessel in arm_transition_vessels.get_children():
			if vessel is Node3D:
				arm_transition_vessel_base_scales[vessel] = vessel.scale


func _update_walk_animation(delta: float) -> void:
	if model == null:
		return

	var planar_speed := Vector2(velocity.x, velocity.z).length()
	var is_walking := planar_speed > 0.08

	if is_summoning:
		var settle := minf(delta * 10.0, 1.0)
		model.position = model.position.lerp(model_base_position, settle)
		model.rotation = model.rotation.lerp(model_base_rotation, settle)
		_lerp_limb_rotation(left_leg, left_leg_base_rotation, settle)
		_lerp_limb_rotation(right_leg, right_leg_base_rotation, settle)
		_lerp_limb_position(left_shoe, left_shoe_base_position, settle)
		_lerp_limb_position(right_shoe, right_shoe_base_position, settle)
	elif is_attacking:
		var settle := minf(delta * 8.0, 1.0)
		model.position = model.position.lerp(model_base_position, settle)
		model.rotation = model.rotation.lerp(model_base_rotation, settle)
		_lerp_limb_rotation(right_arm, right_arm_combat_rotation, settle)
		_lerp_limb_rotation(left_arm, left_arm_combat_rotation, settle)
		_lerp_limb_rotation(left_leg, left_leg_base_rotation, settle)
		_lerp_limb_rotation(right_leg, right_leg_base_rotation, settle)
	elif is_walking:
		var speed_ratio := clampf(planar_speed / maxf(speed, 0.01), 0.35, 1.25)
		walk_phase += delta * walk_animation_speed * speed_ratio
		idle_phase += delta * 1.2

		var step := sin(walk_phase)
		var opposite_step := sin(walk_phase + PI)
		var stride := cos(walk_phase)
		var plant_impact := absf(sin(walk_phase * 2.0))
		var walk_power := clampf(planar_speed / maxf(speed, 0.01), 0.0, 1.0)
		var swing := step * walk_swing_amount * 1.65
		var counter_swing := -swing
		var bob := plant_impact * walk_bob_amount * 1.2 - walk_bob_amount * 0.28
		var sway := step * 0.075 * walk_power
		var shoulder_sway := stride * 0.045 * walk_power
		var lean := walk_power * -0.14
		var left_lift := maxf(0.0, step) * 0.11 * walk_power
		var right_lift := maxf(0.0, opposite_step) * 0.11 * walk_power
		var left_drag := maxf(0.0, -step) * -0.045 * walk_power
		var right_drag := maxf(0.0, step) * -0.045 * walk_power
		var pose_weight := minf(delta * 14.0, 1.0)

		model.position = model.position.lerp(model_base_position + Vector3(sway, bob, shoulder_sway * 0.35), pose_weight)
		model.rotation.x = lerpf(model.rotation.x, lean + plant_impact * 0.025, pose_weight)
		model.rotation.y = lerpf(model.rotation.y, shoulder_sway * -0.45, pose_weight)
		model.rotation.z = lerpf(model.rotation.z, -sway * 1.15, pose_weight)
		_lerp_limb_rotation(left_arm, left_arm_base_rotation + Vector3(swing * 1.08, shoulder_sway * 0.35, -0.08 - sway * 1.4), pose_weight)
		_lerp_limb_rotation(right_arm, right_arm_base_rotation + Vector3(counter_swing * 0.92, shoulder_sway * -0.25, 0.06 + sway * 1.25), pose_weight)
		if not veinmore_active:
			if left_combat_arm != null:
				left_combat_arm.rotation_degrees = left_combat_arm_base_rotation + Vector3(swing * 34.0, shoulder_sway * 18.0, -5.0 - sway * 24.0)
			if right_combat_arm != null:
				right_combat_arm.rotation_degrees = right_combat_arm_base_rotation + Vector3(counter_swing * 30.0, shoulder_sway * -14.0, 4.0 + sway * 22.0)
			if left_forearm_pivot != null:
				left_forearm_pivot.rotation_degrees = left_forearm_base_rotation + Vector3(absf(step) * -8.0, 0.0, -sway * 10.0)
			if right_forearm_pivot != null:
				right_forearm_pivot.rotation_degrees = right_forearm_base_rotation + Vector3(absf(opposite_step) * -8.0, 0.0, sway * 10.0)
		_lerp_limb_rotation(left_leg, left_leg_base_rotation + Vector3(counter_swing * 1.02, 0.0, -sway * 0.65), pose_weight)
		_lerp_limb_rotation(right_leg, right_leg_base_rotation + Vector3(swing * 0.92, 0.0, sway * 0.65), pose_weight)
		_lerp_limb_position(left_shoe, left_shoe_base_position + Vector3(-sway * 0.12, left_lift, stride * -0.055 + left_drag), pose_weight)
		_lerp_limb_position(right_shoe, right_shoe_base_position + Vector3(-sway * 0.12, right_lift, -stride * -0.055 + right_drag), pose_weight)
	else:
		# Low-poly idle breathing keeps the placeholder from looking frozen between inputs.
		idle_phase += delta * 1.35
		var settle := minf(delta * 6.0, 1.0)
		var breath := sin(idle_phase) * 0.022
		var slow_sway := sin(idle_phase * 0.47) * 0.024
		var shoulder_drift := sin(idle_phase * 0.73 + 0.8) * 0.018
		model.position = model.position.lerp(model_base_position + Vector3(slow_sway, breath, shoulder_drift * 0.35), settle)
		model.rotation = model.rotation.lerp(Vector3(breath * -1.25, shoulder_drift * -0.45, slow_sway * -0.75), settle)
		_lerp_limb_rotation(left_arm, left_arm_base_rotation + Vector3(breath * 0.7, shoulder_drift * 0.15, -0.05 + slow_sway * -0.45), settle)
		_lerp_limb_rotation(right_arm, right_arm_base_rotation + Vector3(breath * 0.55, shoulder_drift * -0.12, 0.035 + slow_sway * 0.35), settle)
		if not veinmore_active:
			if left_combat_arm != null:
				left_combat_arm.rotation_degrees = left_combat_arm_base_rotation + Vector3(breath * 22.0, shoulder_drift * 8.0, -3.0 + slow_sway * -10.0)
			if right_combat_arm != null:
				right_combat_arm.rotation_degrees = right_combat_arm_base_rotation + Vector3(breath * 18.0, shoulder_drift * -8.0, 3.0 + slow_sway * 8.0)
			if left_forearm_pivot != null:
				left_forearm_pivot.rotation_degrees = left_forearm_base_rotation + Vector3(breath * 10.0, 0.0, -slow_sway * 8.0)
			if right_forearm_pivot != null:
				right_forearm_pivot.rotation_degrees = right_forearm_base_rotation + Vector3(breath * 10.0, 0.0, slow_sway * 8.0)
		_lerp_limb_rotation(left_leg, left_leg_base_rotation, settle)
		_lerp_limb_rotation(right_leg, right_leg_base_rotation, settle)
		_lerp_limb_position(left_shoe, left_shoe_base_position, settle)
		_lerp_limb_position(right_shoe, right_shoe_base_position, settle)


func _set_limb_rotation(limb: Node3D, target_rotation: Vector3) -> void:
	if limb != null:
		limb.rotation = target_rotation


func _lerp_limb_rotation(limb: Node3D, target_rotation: Vector3, weight: float) -> void:
	if limb != null:
		limb.rotation = limb.rotation.lerp(target_rotation, weight)


func _set_limb_position(limb: Node3D, target_position: Vector3) -> void:
	if limb != null:
		limb.position = target_position


func _lerp_limb_position(limb: Node3D, target_position: Vector3, weight: float) -> void:
	if limb != null:
		limb.position = limb.position.lerp(target_position, weight)


func set_normal_arms_visible(is_visible: bool) -> void:
	for part in [left_arm, right_arm]:
		if part != null:
			part.visible = false


func set_combat_rig_visible(is_visible: bool) -> void:
	for part in [right_combat_arm, left_combat_arm, right_grip_hand, left_grip_hand]:
		if part != null:
			part.visible = true


func set_normal_arms_scale(scale_factor: float) -> void:
	if left_arm != null:
		left_arm.scale = left_arm_base_scale * scale_factor
	if right_arm != null:
		right_arm.scale = right_arm_base_scale * scale_factor


func set_combat_rig_scale(scale_factor: float) -> void:
	if right_combat_arm != null:
		right_combat_arm.scale = right_combat_arm_base_scale * scale_factor
	if left_combat_arm != null:
		left_combat_arm.scale = left_combat_arm_base_scale * scale_factor
	if right_grip_hand != null:
		right_grip_hand.scale = right_grip_hand_base_scale * scale_factor
	if left_grip_hand != null:
		left_grip_hand.scale = left_grip_hand_base_scale * scale_factor


func _set_arm_transition_vessels_visible(is_visible: bool, scale_factor: float = 1.0) -> void:
	if arm_transition_vessels == null:
		return

	for vessel in arm_transition_vessels.get_children():
		if vessel is Node3D:
			var vessel_node := vessel as Node3D
			vessel_node.visible = is_visible
			vessel_node.scale = arm_transition_vessel_base_scales.get(vessel_node, Vector3.ONE) * scale_factor


func _animate_arm_transition_vessels(duration: float) -> void:
	if arm_transition_vessels == null:
		return

	_set_arm_transition_vessels_visible(true, 0.18)
	var vessel_tween := create_tween()
	vessel_tween.set_parallel(true)
	for vessel in arm_transition_vessels.get_children():
		if vessel is Node3D:
			var vessel_node := vessel as Node3D
			var base_scale: Vector3 = arm_transition_vessel_base_scales.get(vessel_node, Vector3.ONE)
			vessel_tween.tween_property(vessel_node, "scale", base_scale * 1.35, duration * 0.42).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			vessel_tween.tween_property(vessel_node, "rotation_degrees", vessel_node.rotation_degrees + Vector3(0.0, 0.0, 18.0), duration * 0.42).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	vessel_tween.chain()
	vessel_tween.set_parallel(true)
	for vessel in arm_transition_vessels.get_children():
		if vessel is Node3D:
			var vessel_node := vessel as Node3D
			vessel_tween.tween_property(vessel_node, "scale", Vector3.ZERO, duration * 0.58).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	vessel_tween.tween_callback(func() -> void: _set_arm_transition_vessels_visible(false, 0.18))


func _set_combat_rig_ready_pose() -> void:
	if hips_pivot != null:
		hips_pivot.position = hips_pivot_base_position
		hips_pivot.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	if combat_torso_pivot != null:
		combat_torso_pivot.position = Vector3(0.0, 0.98, 0.0)
		combat_torso_pivot.rotation_degrees = Vector3(-5.0, 0.0, 0.0)
	if shoulder_pivot != null:
		shoulder_pivot.rotation_degrees = Vector3(-4.0, 0.0, 0.0)
	if right_combat_arm != null:
		right_combat_arm.position = Vector3(0.34, -0.02, -0.1)
		right_combat_arm.rotation_degrees = Vector3(-78.0, 18.0, 26.0)
	if left_combat_arm != null:
		left_combat_arm.position = Vector3(-0.34, -0.02, -0.14)
		left_combat_arm.rotation_degrees = Vector3(-80.0, -20.0, -28.0)
	if right_forearm_pivot != null:
		right_forearm_pivot.rotation_degrees = Vector3(-28.0, 12.0, 8.0)
	if left_forearm_pivot != null:
		left_forearm_pivot.rotation_degrees = Vector3(-32.0, -14.0, -8.0)
	if right_grip_hand != null:
		right_grip_hand.position = Vector3(0.02, -0.43, -0.05)
	if left_grip_hand != null:
		left_grip_hand.position = Vector3(-0.02, -0.43, -0.05)


func _prepare_veinmore() -> void:
	set_normal_arms_visible(true)
	set_normal_arms_scale(1.0)
	set_combat_rig_visible(true)
	set_combat_rig_scale(1.0)
	_set_arm_transition_vessels_visible(false, 0.18)
	if hips_pivot != null:
		hips_pivot.position = hips_pivot_base_position
		hips_pivot.rotation_degrees = hips_pivot_base_rotation
	if combat_torso_pivot != null:
		combat_torso_pivot.position = combat_torso_base_position
		combat_torso_pivot.rotation_degrees = combat_torso_base_rotation
	if shoulder_pivot != null:
		shoulder_pivot.rotation_degrees = shoulder_pivot_base_rotation
	if right_combat_arm != null:
		right_combat_arm.position = right_combat_arm_base_position
		right_combat_arm.rotation_degrees = right_combat_arm_base_rotation
	if left_combat_arm != null:
		left_combat_arm.position = left_combat_arm_base_position
		left_combat_arm.rotation_degrees = left_combat_arm_base_rotation
	if right_forearm_pivot != null:
		right_forearm_pivot.rotation_degrees = right_forearm_base_rotation
	if left_forearm_pivot != null:
		left_forearm_pivot.rotation_degrees = left_forearm_base_rotation
	if right_grip_hand != null:
		right_grip_hand.position = right_grip_hand_base_position
	if left_grip_hand != null:
		left_grip_hand.position = left_grip_hand_base_position
	if veinmore_grip_root != null:
		veinmore_grip_root.position = veinmore_grip_root_base_position
		veinmore_grip_root.rotation_degrees = veinmore_grip_root_base_rotation
	if veinmore_swing_pivot != null:
		veinmore_swing_pivot.rotation_degrees = veinmore_swing_pivot_base_rotation
	if veinmore != null:
		veinmore.visible = false
		veinmore.position = veinmore_base_position
		veinmore.rotation_degrees = veinmore_base_rotation
		veinmore.scale = Vector3.ONE * 0.05
	if extraction_strand != null:
		extraction_strand.visible = false
		extraction_strand.position = extraction_strand_base_position
		extraction_strand.rotation_degrees = extraction_strand_base_rotation
		extraction_strand.scale = extraction_strand_base_scale
	if veinmore_trail != null:
		veinmore_trail.visible = false
		veinmore_trail.position = veinmore_trail_base_position
		veinmore_trail.rotation_degrees = veinmore_trail_base_rotation
		veinmore_trail.scale = veinmore_trail_base_scale
		veinmore_trail.transparency = 1.0
	if veinmore_handle_point != null:
		veinmore_handle_point.visible = false
		veinmore_handle_point.position = veinmore_handle_base_position
		veinmore_handle_point.scale = veinmore_handle_base_scale
	if right_grip_point != null:
		right_grip_point.visible = true
		right_grip_point.position = right_grip_point_base_position
		right_grip_point.scale = right_grip_point_base_scale
	if left_grip_point != null:
		left_grip_point.visible = true
		left_grip_point.position = left_grip_point_base_position
		left_grip_point.scale = left_grip_point_base_scale
	if veinmore_hitbox != null:
		veinmore_hitbox.monitoring = false


func _handle_attack_input() -> void:
	if is_summoning or is_attacking or is_dismissing:
		return

	if not veinmore_active:
		_summon_veinmore()
	else:
		_heavy_slash()


func _handle_dismiss_input() -> void:
	if is_summoning or is_attacking or is_dismissing or not veinmore_active:
		return

	_dismiss_veinmore()


func _dismiss_veinmore() -> void:
	is_dismissing = true
	veinmore_active = false
	movement_locked = true
	_end_damage_window()
	_hide_veinmore_trail()
	set_normal_arms_visible(true)
	set_normal_arms_scale(0.05)
	set_combat_rig_visible(true)
	set_combat_rig_scale(1.0)
	_animate_arm_transition_vessels(0.32)

	var dismiss_time := 0.36
	var tween := create_tween()
	tween.set_parallel(true)
	if veinmore != null:
		tween.tween_property(veinmore, "scale", Vector3.ONE * 0.05, dismiss_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if veinmore_handle_point != null:
		tween.tween_property(veinmore_handle_point, "scale", Vector3.ONE * 0.05, dismiss_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if right_grip_point != null:
		tween.tween_property(right_grip_point, "scale", Vector3.ONE * 0.05, dismiss_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if left_grip_point != null:
		tween.tween_property(left_grip_point, "scale", Vector3.ONE * 0.05, dismiss_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if right_combat_arm != null:
		tween.tween_property(right_combat_arm, "scale", right_combat_arm_base_scale * 0.05, dismiss_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if left_combat_arm != null:
		tween.tween_property(left_combat_arm, "scale", left_combat_arm_base_scale * 0.05, dismiss_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if right_grip_hand != null:
		tween.tween_property(right_grip_hand, "scale", right_grip_hand_base_scale * 0.05, dismiss_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if left_grip_hand != null:
		tween.tween_property(left_grip_hand, "scale", left_grip_hand_base_scale * 0.05, dismiss_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if left_arm != null:
		tween.tween_property(left_arm, "scale", left_arm_base_scale, dismiss_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if right_arm != null:
		tween.tween_property(right_arm, "scale", right_arm_base_scale, dismiss_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await tween.finished
	_prepare_veinmore()
	_restore_normal_visual_pose()
	is_dismissing = false
	movement_locked = false


func _restore_normal_visual_pose() -> void:
	reset_visual_pose(true)


func reset_visual_pose(include_arms: bool = true) -> void:
	if model != null:
		model.position = model_base_position
		model.rotation = model_base_rotation
	if include_arms:
		_set_limb_rotation(left_arm, left_arm_base_rotation)
		_set_limb_rotation(right_arm, right_arm_base_rotation)
	_set_limb_rotation(left_leg, left_leg_base_rotation)
	_set_limb_rotation(right_leg, right_leg_base_rotation)
	_set_limb_position(left_shoe, left_shoe_base_position)
	_set_limb_position(right_shoe, right_shoe_base_position)


func _summon_veinmore() -> void:
	if veinmore == null:
		return

	is_summoning = true
	movement_locked = true
	set_normal_arms_visible(true)
	set_normal_arms_scale(1.0)
	set_combat_rig_visible(true)
	set_combat_rig_scale(0.05)
	_set_combat_rig_ready_pose()
	_animate_arm_transition_vessels(summon_duration * 0.5)
	if veinmore_grip_root != null:
		veinmore_grip_root.position = Vector3(-0.1, -0.08, -0.38)
		veinmore_grip_root.rotation_degrees = Vector3(-10.0, 0.0, 0.0)
	if veinmore_swing_pivot != null:
		veinmore_swing_pivot.rotation_degrees = Vector3(0.0, -18.0, 0.0)
	veinmore.visible = true
	veinmore.scale = Vector3(0.04, 0.04, 0.16)
	veinmore.position = Vector3(0.04, -0.18, 0.2)
	veinmore.rotation_degrees = Vector3(-88.0, -12.0, -28.0)
	if extraction_strand != null:
		extraction_strand.visible = true
		extraction_strand.position = extraction_strand_base_position + Vector3(-0.02, -0.03, 0.02)
		extraction_strand.scale = Vector3(0.08, 0.08, 0.24)
		extraction_strand.rotation_degrees = Vector3(-22.0, 0.0, -12.0)
	reset_visual_pose(false)

	var brace_time := summon_duration * 0.18
	var draw_time := summon_duration * 0.58
	var settle_time := summon_duration * 0.24

	var tween := create_tween()
	tween.set_parallel(true)
	if right_arm != null:
		tween.tween_property(right_arm, "rotation", right_arm_base_rotation + Vector3(-0.88, -0.18, 0.48), brace_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_arm != null:
		tween.tween_property(left_arm, "rotation", left_arm_base_rotation + Vector3(0.24, 0.08, -0.18), brace_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_arm != null:
		tween.tween_property(right_arm, "scale", right_arm_base_scale * 0.08, brace_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if left_arm != null:
		tween.tween_property(left_arm, "scale", left_arm_base_scale * 0.08, brace_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if right_combat_arm != null:
		tween.tween_property(right_combat_arm, "scale", right_combat_arm_base_scale * 0.72, brace_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if left_combat_arm != null:
		tween.tween_property(left_combat_arm, "scale", left_combat_arm_base_scale * 0.72, brace_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if right_grip_hand != null:
		tween.tween_property(right_grip_hand, "scale", right_grip_hand_base_scale * 0.72, brace_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if left_grip_hand != null:
		tween.tween_property(left_grip_hand, "scale", left_grip_hand_base_scale * 0.72, brace_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(veinmore, "position", Vector3(0.0, -0.1, 0.12), brace_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if extraction_strand != null:
		tween.tween_property(extraction_strand, "position", extraction_strand_base_position + Vector3(-0.04, -0.02, -0.06), brace_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(extraction_strand, "scale", Vector3(0.42, 1.15, 0.42), brace_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.chain()
	tween.tween_callback(func() -> void: set_normal_arms_visible(false))
	tween.set_parallel(true)
	tween.tween_property(veinmore, "scale", Vector3(0.48, 0.82, 0.78), draw_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(veinmore, "position", Vector3(0.0, -0.02, -0.18), draw_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(veinmore, "rotation_degrees", Vector3(-38.0, -6.0, -16.0), draw_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if right_arm != null:
		tween.tween_property(right_arm, "rotation", right_arm_combat_rotation + Vector3(-0.18, -0.08, 0.18), draw_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if left_arm != null:
		tween.tween_property(left_arm, "rotation", left_arm_base_rotation + Vector3(0.34, 0.0, -0.2), draw_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if right_combat_arm != null:
		tween.tween_property(right_combat_arm, "scale", right_combat_arm_base_scale, draw_time * 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if left_combat_arm != null:
		tween.tween_property(left_combat_arm, "scale", left_combat_arm_base_scale, draw_time * 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if right_grip_hand != null:
		tween.tween_property(right_grip_hand, "scale", right_grip_hand_base_scale, draw_time * 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if left_grip_hand != null:
		tween.tween_property(left_grip_hand, "scale", left_grip_hand_base_scale, draw_time * 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if extraction_strand != null:
		tween.tween_property(extraction_strand, "position", extraction_strand_base_position + Vector3(-0.08, -0.02, -0.16), draw_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.tween_property(extraction_strand, "scale", Vector3(0.85, 1.75, 0.85), draw_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	tween.chain()
	tween.set_parallel(true)
	tween.tween_property(veinmore, "scale", veinmore_ready_scale, settle_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(veinmore, "position", veinmore_base_position, settle_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(veinmore, "rotation_degrees", veinmore_base_rotation, settle_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if weapon_attachment != null:
		tween.tween_property(weapon_attachment, "rotation_degrees", weapon_attachment_ready_rotation, settle_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if veinmore_grip_root != null:
		tween.tween_property(veinmore_grip_root, "position", Vector3(-0.1, -0.08, -0.38), settle_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(veinmore_grip_root, "rotation_degrees", Vector3(-10.0, 0.0, 0.0), settle_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if veinmore_swing_pivot != null:
		tween.tween_property(veinmore_swing_pivot, "rotation_degrees", Vector3(0.0, -18.0, 0.0), settle_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if right_arm != null:
		tween.tween_property(right_arm, "rotation", right_arm_combat_rotation, settle_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_arm != null:
		tween.tween_property(left_arm, "rotation", left_arm_combat_rotation, settle_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if combat_torso_pivot != null:
		tween.tween_property(combat_torso_pivot, "position", Vector3(0.0, 0.98, 0.0), settle_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(combat_torso_pivot, "rotation_degrees", Vector3(-5.0, 0.0, 0.0), settle_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if shoulder_pivot != null:
		tween.tween_property(shoulder_pivot, "rotation_degrees", Vector3(-4.0, 0.0, 0.0), settle_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_combat_arm != null:
		tween.tween_property(right_combat_arm, "position", Vector3(0.34, -0.02, -0.1), settle_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(right_combat_arm, "rotation_degrees", Vector3(-78.0, 18.0, 26.0), settle_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_combat_arm != null:
		tween.tween_property(left_combat_arm, "position", Vector3(-0.34, -0.02, -0.14), settle_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(left_combat_arm, "rotation_degrees", Vector3(-80.0, -20.0, -28.0), settle_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_forearm_pivot != null:
		tween.tween_property(right_forearm_pivot, "rotation_degrees", Vector3(-28.0, 12.0, 8.0), settle_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_forearm_pivot != null:
		tween.tween_property(left_forearm_pivot, "rotation_degrees", Vector3(-32.0, -14.0, -8.0), settle_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_grip_hand != null:
		tween.tween_property(right_grip_hand, "position", Vector3(0.02, -0.43, -0.05), settle_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_grip_hand != null:
		tween.tween_property(left_grip_hand, "position", Vector3(-0.02, -0.43, -0.05), settle_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if extraction_strand != null:
		tween.tween_property(extraction_strand, "scale", Vector3(0.05, 0.05, 0.05), settle_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await tween.finished
	if extraction_strand != null:
		extraction_strand.visible = false
	if veinmore_handle_point != null:
		veinmore_handle_point.visible = true
		veinmore_handle_point.position = veinmore_handle_base_position
		veinmore_handle_point.scale = veinmore_handle_base_scale
	if right_grip_point != null:
		right_grip_point.visible = true
		right_grip_point.position = right_grip_point_base_position
		right_grip_point.scale = right_grip_point_base_scale
	if left_grip_point != null:
		left_grip_point.visible = true
		left_grip_point.position = left_grip_point_base_position
		left_grip_point.scale = left_grip_point_base_scale
	print("VEINMORE_READY")
	veinmore_active = true
	is_summoning = false
	movement_locked = false
	reset_visual_pose(false)


func _heavy_slash() -> void:
	if weapon_attachment == null or veinmore_swing_pivot == null:
		return

	is_attacking = true
	movement_locked = true
	damaged_this_slash.clear()

	print("VEINMORE_READY")
	print("VEINMORE_WINDUP")
	set_normal_arms_visible(false)
	set_combat_rig_visible(true)
	_set_combat_rig_ready_pose()
	weapon_attachment.rotation_degrees = weapon_attachment_ready_rotation
	if veinmore_grip_root != null:
		veinmore_grip_root.position = Vector3(-0.1, -0.08, -0.38)
		veinmore_grip_root.rotation_degrees = Vector3(-10.0, 0.0, 0.0)
	veinmore_swing_pivot.rotation_degrees = Vector3(0.0, -18.0, 0.0)
	if veinmore_handle_point != null:
		veinmore_handle_point.visible = true
		veinmore_handle_point.position = Vector3(-0.1, -0.035, -0.33)
	if right_grip_point != null:
		right_grip_point.visible = true
		right_grip_point.position = Vector3(0.02, -0.045, -0.22)
	if left_grip_point != null:
		left_grip_point.visible = true
		left_grip_point.position = Vector3(-0.22, -0.045, -0.48)

	var windup_time := 0.62
	var active_time := 0.34
	var follow_time := 0.44
	var recovery_time := 0.58

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(veinmore_swing_pivot, "rotation_degrees", Vector3(0.0, -148.0, 0.0), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if veinmore_grip_root != null:
		tween.tween_property(veinmore_grip_root, "position", Vector3(0.08, -0.14, -0.42), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(veinmore_grip_root, "rotation_degrees", Vector3(-18.0, -14.0, -10.0), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if hips_pivot != null:
		tween.tween_property(hips_pivot, "position", hips_pivot_base_position + Vector3(0.0, -0.055, 0.0), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(hips_pivot, "rotation_degrees", Vector3(0.0, -16.0, 0.0), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if right_arm != null:
		tween.tween_property(right_arm, "rotation", right_arm_base_rotation + Vector3(-1.65, -0.36, 1.02), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if left_arm != null:
		tween.tween_property(left_arm, "rotation", left_arm_base_rotation + Vector3(-1.5, -1.08, -0.86), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if veinmore_handle_point != null:
		tween.tween_property(veinmore_handle_point, "position", Vector3(-0.08, -0.05, -0.38), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if right_grip_point != null:
		tween.tween_property(right_grip_point, "position", Vector3(0.06, -0.065, -0.28), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if left_grip_point != null:
		tween.tween_property(left_grip_point, "position", Vector3(-0.26, -0.065, -0.54), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if combat_torso_pivot != null:
		tween.tween_property(combat_torso_pivot, "position", Vector3(-0.08, 0.9, -0.24), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(combat_torso_pivot, "rotation_degrees", Vector3(-18.0, -38.0, -18.0), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if shoulder_pivot != null:
		tween.tween_property(shoulder_pivot, "rotation_degrees", Vector3(-8.0, -28.0, -10.0), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if right_combat_arm != null:
		tween.tween_property(right_combat_arm, "position", Vector3(0.28, -0.14, -0.34), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(right_combat_arm, "rotation_degrees", Vector3(-98.0, -32.0, 58.0), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if left_combat_arm != null:
		tween.tween_property(left_combat_arm, "position", Vector3(-0.18, -0.14, -0.44), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(left_combat_arm, "rotation_degrees", Vector3(-104.0, -58.0, -54.0), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if right_forearm_pivot != null:
		tween.tween_property(right_forearm_pivot, "rotation_degrees", Vector3(-42.0, -28.0, 18.0), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if left_forearm_pivot != null:
		tween.tween_property(left_forearm_pivot, "rotation_degrees", Vector3(-48.0, -34.0, -20.0), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if right_grip_hand != null:
		tween.tween_property(right_grip_hand, "position", Vector3(0.06, -0.13, -0.36), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	if left_grip_hand != null:
		tween.tween_property(left_grip_hand, "position", Vector3(-0.22, -0.13, -0.54), windup_time).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(_begin_veinmore_active)
	tween.set_parallel(true)
	tween.tween_property(veinmore_swing_pivot, "rotation_degrees", Vector3(0.0, 154.0, 0.0), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if veinmore_grip_root != null:
		tween.tween_property(veinmore_grip_root, "position", Vector3(-0.14, -0.16, -0.46), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.tween_property(veinmore_grip_root, "rotation_degrees", Vector3(-12.0, 20.0, 14.0), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if hips_pivot != null:
		tween.tween_property(hips_pivot, "position", hips_pivot_base_position + Vector3(0.0, -0.065, 0.0), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.tween_property(hips_pivot, "rotation_degrees", Vector3(0.0, 22.0, 0.0), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if right_arm != null:
		tween.tween_property(right_arm, "rotation", right_arm_base_rotation + Vector3(-0.24, 0.98, 0.62), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if left_arm != null:
		tween.tween_property(left_arm, "rotation", left_arm_base_rotation + Vector3(-0.18, 0.92, -0.04), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if veinmore_handle_point != null:
		tween.tween_property(veinmore_handle_point, "position", Vector3(-0.12, -0.055, -0.34), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if right_grip_point != null:
		tween.tween_property(right_grip_point, "position", Vector3(0.0, -0.07, -0.24), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if left_grip_point != null:
		tween.tween_property(left_grip_point, "position", Vector3(-0.24, -0.07, -0.5), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if combat_torso_pivot != null:
		tween.tween_property(combat_torso_pivot, "position", Vector3(0.08, 0.88, -0.28), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.tween_property(combat_torso_pivot, "rotation_degrees", Vector3(16.0, 42.0, 24.0), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if shoulder_pivot != null:
		tween.tween_property(shoulder_pivot, "rotation_degrees", Vector3(10.0, 46.0, 18.0), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if right_combat_arm != null:
		tween.tween_property(right_combat_arm, "position", Vector3(0.12, -0.16, -0.38), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.tween_property(right_combat_arm, "rotation_degrees", Vector3(-58.0, 62.0, 30.0), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if left_combat_arm != null:
		tween.tween_property(left_combat_arm, "position", Vector3(-0.26, -0.16, -0.48), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		tween.tween_property(left_combat_arm, "rotation_degrees", Vector3(-54.0, 72.0, -16.0), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if right_forearm_pivot != null:
		tween.tween_property(right_forearm_pivot, "rotation_degrees", Vector3(-24.0, 48.0, 10.0), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if left_forearm_pivot != null:
		tween.tween_property(left_forearm_pivot, "rotation_degrees", Vector3(-22.0, 56.0, -8.0), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if right_grip_hand != null:
		tween.tween_property(right_grip_hand, "position", Vector3(0.0, -0.14, -0.34), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	if left_grip_hand != null:
		tween.tween_property(left_grip_hand, "position", Vector3(-0.22, -0.14, -0.5), active_time).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(func() -> void: print("VEINMORE_FOLLOW_THROUGH"))
	tween.set_parallel(true)
	tween.tween_property(veinmore_swing_pivot, "rotation_degrees", Vector3(0.0, 198.0, 0.0), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if veinmore_grip_root != null:
		tween.tween_property(veinmore_grip_root, "position", Vector3(-0.22, -0.1, -0.4), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(veinmore_grip_root, "rotation_degrees", Vector3(-8.0, 28.0, 20.0), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if hips_pivot != null:
		tween.tween_property(hips_pivot, "position", hips_pivot_base_position + Vector3(0.0, -0.035, 0.0), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(hips_pivot, "rotation_degrees", Vector3(0.0, 16.0, 0.0), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_arm != null:
		tween.tween_property(right_arm, "rotation", right_arm_base_rotation + Vector3(-0.08, 1.08, 0.44), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_arm != null:
		tween.tween_property(left_arm, "rotation", left_arm_base_rotation + Vector3(-0.04, 1.02, 0.04), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if veinmore_handle_point != null:
		tween.tween_property(veinmore_handle_point, "position", Vector3(-0.14, -0.045, -0.3), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_grip_point != null:
		tween.tween_property(right_grip_point, "position", Vector3(-0.02, -0.055, -0.2), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_grip_point != null:
		tween.tween_property(left_grip_point, "position", Vector3(-0.22, -0.055, -0.44), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if combat_torso_pivot != null:
		tween.tween_property(combat_torso_pivot, "position", Vector3(0.12, 0.92, -0.22), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(combat_torso_pivot, "rotation_degrees", Vector3(8.0, 30.0, 20.0), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if shoulder_pivot != null:
		tween.tween_property(shoulder_pivot, "rotation_degrees", Vector3(6.0, 34.0, 16.0), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_combat_arm != null:
		tween.tween_property(right_combat_arm, "position", Vector3(0.08, -0.1, -0.32), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(right_combat_arm, "rotation_degrees", Vector3(-44.0, 72.0, 20.0), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_combat_arm != null:
		tween.tween_property(left_combat_arm, "position", Vector3(-0.22, -0.1, -0.42), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(left_combat_arm, "rotation_degrees", Vector3(-42.0, 78.0, -8.0), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_forearm_pivot != null:
		tween.tween_property(right_forearm_pivot, "rotation_degrees", Vector3(-16.0, 62.0, 8.0), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_forearm_pivot != null:
		tween.tween_property(left_forearm_pivot, "rotation_degrees", Vector3(-14.0, 66.0, -6.0), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_grip_hand != null:
		tween.tween_property(right_grip_hand, "position", Vector3(-0.02, -0.09, -0.3), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_grip_hand != null:
		tween.tween_property(left_grip_hand, "position", Vector3(-0.2, -0.09, -0.44), follow_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(_end_damage_window)
	tween.tween_callback(func() -> void: print("VEINMORE_RECOVERY"))
	tween.set_parallel(true)
	tween.tween_property(veinmore_swing_pivot, "rotation_degrees", Vector3(0.0, -18.0, 0.0), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if veinmore_grip_root != null:
		tween.tween_property(veinmore_grip_root, "position", Vector3(-0.1, -0.08, -0.38), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(veinmore_grip_root, "rotation_degrees", Vector3(-10.0, 0.0, 0.0), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if hips_pivot != null:
		tween.tween_property(hips_pivot, "position", hips_pivot_base_position, recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(hips_pivot, "rotation_degrees", Vector3.ZERO, recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_arm != null:
		tween.tween_property(right_arm, "rotation", right_arm_combat_rotation, recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_arm != null:
		tween.tween_property(left_arm, "rotation", left_arm_combat_rotation, recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if veinmore_handle_point != null:
		tween.tween_property(veinmore_handle_point, "position", veinmore_handle_base_position, recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_grip_point != null:
		tween.tween_property(right_grip_point, "position", right_grip_point_base_position, recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_grip_point != null:
		tween.tween_property(left_grip_point, "position", left_grip_point_base_position, recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if combat_torso_pivot != null:
		tween.tween_property(combat_torso_pivot, "position", Vector3(0.0, 0.98, 0.0), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(combat_torso_pivot, "rotation_degrees", Vector3(-5.0, 0.0, 0.0), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if shoulder_pivot != null:
		tween.tween_property(shoulder_pivot, "rotation_degrees", Vector3(-4.0, 0.0, 0.0), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_combat_arm != null:
		tween.tween_property(right_combat_arm, "position", Vector3(0.34, -0.02, -0.1), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(right_combat_arm, "rotation_degrees", Vector3(-78.0, 18.0, 26.0), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_combat_arm != null:
		tween.tween_property(left_combat_arm, "position", Vector3(-0.34, -0.02, -0.14), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(left_combat_arm, "rotation_degrees", Vector3(-80.0, -20.0, -28.0), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_forearm_pivot != null:
		tween.tween_property(right_forearm_pivot, "rotation_degrees", Vector3(-28.0, 12.0, 8.0), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_forearm_pivot != null:
		tween.tween_property(left_forearm_pivot, "rotation_degrees", Vector3(-32.0, -14.0, -8.0), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if right_grip_hand != null:
		tween.tween_property(right_grip_hand, "position", Vector3(0.02, -0.43, -0.05), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if left_grip_hand != null:
		tween.tween_property(left_grip_hand, "position", Vector3(-0.02, -0.43, -0.05), recovery_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished
	is_attacking = false
	movement_locked = false
	reset_visual_pose(false)


func _begin_veinmore_active() -> void:
	print("VEINMORE_ACTIVE")
	_begin_damage_window()


func _begin_damage_window() -> void:
	if veinmore_hitbox != null:
		veinmore_hitbox.monitoring = true
	_trigger_camera_feedback(0.04, 0.09)
	if veinmore_trail != null:
		veinmore_trail.visible = true
		veinmore_trail.transparency = 0.72
		veinmore_trail.scale = Vector3(0.18, 1.0, 0.62)
		veinmore_trail.position = Vector3(-0.56, 0.02, -1.0)
		veinmore_trail.rotation_degrees = Vector3(-8.0, 0.0, 68.0)
		var trail_tween := create_tween()
		trail_tween.set_parallel(true)
		trail_tween.tween_property(veinmore_trail, "scale", Vector3(3.1, 1.0, 1.95), 0.22).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		trail_tween.tween_property(veinmore_trail, "position", Vector3(0.54, -0.03, -1.14), 0.22).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		trail_tween.tween_property(veinmore_trail, "rotation_degrees", Vector3(-8.0, 0.0, -68.0), 0.22).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		trail_tween.tween_property(veinmore_trail, "transparency", 0.08, 0.04)
		trail_tween.chain().tween_property(veinmore_trail, "transparency", 1.0, 0.34).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		trail_tween.tween_callback(_hide_veinmore_trail)


func _end_damage_window() -> void:
	if veinmore_hitbox != null:
		veinmore_hitbox.monitoring = false


func _hide_veinmore_trail() -> void:
	if veinmore_trail == null:
		return

	veinmore_trail.visible = false
	veinmore_trail.position = veinmore_trail_base_position
	veinmore_trail.rotation_degrees = veinmore_trail_base_rotation
	veinmore_trail.scale = veinmore_trail_base_scale
	veinmore_trail.transparency = 1.0


func _check_veinmore_hits() -> void:
	if veinmore_hitbox == null or not veinmore_hitbox.monitoring:
		return

	for body in veinmore_hitbox.get_overlapping_bodies():
		if body in damaged_this_slash:
			continue
		if body.has_method("take_hit"):
			damaged_this_slash.append(body)
			var hit_direction := body.global_position - global_position
			var defeated: bool = body.take_hit(slash_damage, hit_direction)
			if defeated:
				_trigger_camera_feedback(0.1, 0.18)
			else:
				_trigger_camera_feedback(0.05, 0.1)


func _trigger_camera_feedback(amount: float, duration: float) -> void:
	if follow_camera != null and follow_camera.has_method("add_shake"):
		follow_camera.add_shake(amount, duration)
