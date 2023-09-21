extends Area3D

var speed = 3;

var rotate = 0;

func _ready():
	randomize();
	speed = randf_range(1, 2);
	rotation.y = deg_to_rad(randf_range(0, 360));

func _process(_delta):
	if $front.is_colliding():
		rotation.y += _delta * 5;
	else:
		position += -global_transform.basis.z * speed * _delta;
		
		rotation.y = lerp_angle(rotation.y, rotate, 0.3 * _delta);

func _on_timer_timeout():
	rotate = deg_to_rad(randf_range(0, 360));
