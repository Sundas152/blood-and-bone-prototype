extends Node3D

@export var player_path: NodePath = NodePath("../Player")
@export var reset_marker_path: NodePath = NodePath("PlayerSpawn")
@export var fall_reset_y: float = -2.0
@export var room_half_extents: Vector2 = Vector2(8.4, 6.0)

var player: Node3D
var reset_marker: Marker3D


func _ready() -> void:
	player = get_node_or_null(player_path) as Node3D
	reset_marker = get_node_or_null(reset_marker_path) as Marker3D


func _physics_process(_delta: float) -> void:
	if player == null:
		player = get_node_or_null(player_path) as Node3D
	if player == null:
		return

	# Safety net for prototype testing: keep the player inside the playable room volume.
	if player.global_position.y < fall_reset_y or _is_outside_room(player.global_position):
		_reset_player()


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
