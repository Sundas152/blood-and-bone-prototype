extends Node3D

@export var player_path: NodePath
@export var spawn_path: NodePath


func _ready() -> void:
	# Keep spawning data in the room scene so future rooms can define their own start point.
	var player := get_node_or_null(player_path) as Node3D
	var spawn := get_node_or_null(spawn_path) as Marker3D

	if player == null or spawn == null:
		return

	player.global_position = spawn.global_position
