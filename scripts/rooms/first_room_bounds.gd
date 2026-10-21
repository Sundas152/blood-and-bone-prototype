extends Node3D

const EXIT_PULSE_HALF_CYCLE: float = 0.5
const EXIT_PULSE_EMISSION_LOW: Color = Color(0.96, 0.76, 0.36, 1.0)
const EXIT_PULSE_EMISSION_HIGH: Color = Color(1.0, 0.9, 0.62, 1.0)
const EXIT_PULSE_EMISSION_ENERGY_LOW: float = 2.4
const EXIT_PULSE_EMISSION_ENERGY_HIGH: float = 3.4

@export var player_path: NodePath = NodePath("../Player")
@export var reset_marker_path: NodePath = NodePath("PlayerSpawn")
@export var fall_reset_y: float = -2.0
@export var room_half_extents: Vector2 = Vector2(8.4, 6.0)
@export var completion_target_path: NodePath = NodePath("BloodMage_Static_Test_01")
@export var exit_path: NodePath = NodePath("Exit")
@export var exit_threshold_path: NodePath = NodePath("Exit/Threshold")
@export var exit_guide_light_path: NodePath = NodePath("Exit/ExitGuideLight")
@export var exit_reach_distance: float = 1.5
@export var completion_reset_delay: float = 0.75

var player: Node3D
var reset_marker: Marker3D
var completion_target: Node
var completion_target_was_resolved: bool = false
var exit_marker: Node3D
var exit_threshold: MeshInstance3D
var exit_guide_light: OmniLight3D
var exit_active: bool = false
var session_completing: bool = false
var threshold_base_material_override: Material
var exit_light_base_color: Color
var exit_light_base_energy: float
var active_exit_material: StandardMaterial3D
var completion_reset_timer: SceneTreeTimer
var exit_pulse_tween: Tween


func _ready() -> void:
	player = get_node_or_null(player_path) as Node3D
	reset_marker = get_node_or_null(reset_marker_path) as Marker3D
	completion_target = get_node_or_null(completion_target_path)
	completion_target_was_resolved = completion_target != null
	exit_marker = get_node_or_null(exit_path) as Node3D
	exit_threshold = get_node_or_null(exit_threshold_path) as MeshInstance3D
	exit_guide_light = get_node_or_null(exit_guide_light_path) as OmniLight3D

	if not completion_target_was_resolved:
		push_warning("Training-room exit disabled: completion target not found.")
	if exit_marker == null or exit_threshold == null or exit_guide_light == null:
		push_warning("Training-room exit disabled: exit marker, threshold, or guide light not found.")
		return

	threshold_base_material_override = exit_threshold.material_override
	exit_light_base_color = exit_guide_light.light_color
	exit_light_base_energy = exit_guide_light.light_energy
	active_exit_material = StandardMaterial3D.new()
	active_exit_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	active_exit_material.albedo_color = Color(0.92, 0.78, 0.42, 1.0)
	active_exit_material.emission_enabled = true
	active_exit_material.emission = Color(0.92, 0.68, 0.24, 1.0)
	active_exit_material.emission_energy_multiplier = 1.8
	_set_exit_inactive()


func _physics_process(_delta: float) -> void:
	if player == null:
		player = get_node_or_null(player_path) as Node3D
	if player == null:
		return

	# Safety net for prototype testing: keep the player inside the playable room volume.
	if player.global_position.y < fall_reset_y or _is_outside_room(player.global_position):
		_reset_player()

	if not exit_active:
		_check_for_completion_target_defeat()
	if exit_active and not session_completing and _has_player_reached_exit():
		_begin_session_completion()


func _is_outside_room(world_position: Vector3) -> bool:
	var local_position := global_transform.affine_inverse() * world_position
	return absf(local_position.x) > room_half_extents.x or absf(local_position.z) > room_half_extents.y


func _reset_player() -> void:
	if reset_marker == null:
		reset_marker = get_node_or_null(reset_marker_path) as Marker3D
	if reset_marker == null:
		return

	player.global_position = reset_marker.global_position
	if player is CharacterBody3D:
		var body := player as CharacterBody3D
		body.velocity = Vector3.ZERO


func _set_exit_inactive() -> void:
	if exit_pulse_tween != null:
		exit_pulse_tween.kill()
		exit_pulse_tween = null
	exit_active = false
	exit_threshold.material_override = threshold_base_material_override
	exit_guide_light.light_color = exit_light_base_color.darkened(0.55)
	exit_guide_light.light_energy = exit_light_base_energy * 0.28


func _check_for_completion_target_defeat() -> void:
	if not completion_target_was_resolved or not is_instance_valid(completion_target):
		return
	if completion_target.get("defeated") == true:
		_activate_exit()


func _activate_exit() -> void:
	if exit_active or exit_marker == null or exit_threshold == null or exit_guide_light == null:
		return
	exit_active = true
	exit_threshold.material_override = active_exit_material
	exit_guide_light.light_color = Color(0.96, 0.72, 0.3, 1.0)
	_start_exit_pulse()
	print("TRAINING_EXIT_ACTIVE")


func _start_exit_pulse() -> void:
	if exit_pulse_tween != null:
		exit_pulse_tween.kill()

	var light_energy_low: float = maxf(exit_light_base_energy * 2.6, 2.0)
	var light_energy_high: float = maxf(exit_light_base_energy * 3.8, 2.8)
	active_exit_material.emission = EXIT_PULSE_EMISSION_LOW
	active_exit_material.emission_energy_multiplier = EXIT_PULSE_EMISSION_ENERGY_LOW
	exit_guide_light.light_energy = light_energy_low

	exit_pulse_tween = create_tween().bind_node(self)
	exit_pulse_tween.set_loops()
	exit_pulse_tween.set_trans(Tween.TRANS_SINE)
	exit_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	exit_pulse_tween.tween_property(
		active_exit_material,
		"emission",
		EXIT_PULSE_EMISSION_HIGH,
		EXIT_PULSE_HALF_CYCLE
	)
	exit_pulse_tween.parallel().tween_property(
		active_exit_material,
		"emission_energy_multiplier",
		EXIT_PULSE_EMISSION_ENERGY_HIGH,
		EXIT_PULSE_HALF_CYCLE
	)
	exit_pulse_tween.parallel().tween_property(
		exit_guide_light,
		"light_energy",
		light_energy_high,
		EXIT_PULSE_HALF_CYCLE
	)
	exit_pulse_tween.tween_property(
		active_exit_material,
		"emission",
		EXIT_PULSE_EMISSION_LOW,
		EXIT_PULSE_HALF_CYCLE
	)
	exit_pulse_tween.parallel().tween_property(
		active_exit_material,
		"emission_energy_multiplier",
		EXIT_PULSE_EMISSION_ENERGY_LOW,
		EXIT_PULSE_HALF_CYCLE
	)
	exit_pulse_tween.parallel().tween_property(
		exit_guide_light,
		"light_energy",
		light_energy_low,
		EXIT_PULSE_HALF_CYCLE
	)


func _has_player_reached_exit() -> bool:
	if exit_marker == null:
		return false
	var to_exit := exit_marker.global_position - player.global_position
	to_exit.y = 0.0
	return to_exit.length() <= exit_reach_distance


func _begin_session_completion() -> void:
	if session_completing:
		return
	var player_defeated = player.get("defeated")
	if player_defeated is bool and player_defeated:
		return
	session_completing = true

	if player is CharacterBody3D:
		var body := player as CharacterBody3D
		body.velocity = Vector3.ZERO
	player.set("movement_locked", true)
	if player.has_method("_end_damage_window"):
		player.call("_end_damage_window")
	if player.has_method("_hide_veinmore_trail"):
		player.call("_hide_veinmore_trail")

	var veinmore_hitbox := player.get_node_or_null("VeinmoreHitbox") as Area3D
	if veinmore_hitbox != null:
		veinmore_hitbox.monitoring = false
	var veinmore_trail := player.get_node_or_null("Model/VisualRoot/HipsPivot/TorsoPivot/ShoulderPivot/VeinmoreGripRoot/VeinmoreSwingPivot/VeinmoreTrail") as MeshInstance3D
	if veinmore_trail != null:
		veinmore_trail.visible = false

	player.process_mode = Node.PROCESS_MODE_DISABLED
	print("TRAINING_SESSION_COMPLETE")
	var scene_tree := get_tree()
	completion_reset_timer = scene_tree.create_timer(maxf(completion_reset_delay, 0.01))
	completion_reset_timer.timeout.connect(Callable(scene_tree, "reload_current_scene"), CONNECT_ONE_SHOT)
