extends Node3D


func _process(delta):
	if $RayCast3D.is_colliding():
		position.y = $RayCast3D.get_collision_point().y;
		set_process_mode(PROCESS_MODE_DISABLED);
