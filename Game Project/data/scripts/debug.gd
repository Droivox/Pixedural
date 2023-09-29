extends Control

func _process(_delta) -> void:
	$fps.text = str(Engine.get_frames_per_second());
	
	var pos = $"../Character".global_position;
	pos.x = int(pos.x);
	pos.y = int(pos.y);
	pos.z = int(pos.z);
	
	$pos.text = str(pos);


func _ready():
	pass
