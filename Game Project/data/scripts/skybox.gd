extends Node3D

func _ready():
	pass

func _process(delta):
	position = get_viewport().get_camera_3d().global_position;
