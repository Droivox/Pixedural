extends CharacterBody3D

var speed = 3;

var rotate = 0;

@export var helper : Node3D;

var playerInRange = false;

func _ready():
	randomize();
	speed = randf_range(1, 2);
	rotation.y = deg_to_rad(randf_range(0, 360));

func _process(_delta):
	movement(_delta);
	helperMovementAndRotation(_delta);

func movement(_delta):
	pass

func helperMovementAndRotation(_delta):
	var rays = [$helper/Front];
	
	var rayCollision = false;
	
	for ray in rays:
		if ray.is_colliding():
			var normal = ray.get_collision_normal();
			var point = ray.get_collision_point();

			var a = point - (point + normal);

			var angle = atan2(a.x, a.z);

			helper.rotation.y = angle;

	helper.rotation.y = lerp_angle(helper.rotation.y, rotate, 0.3 * _delta);
	helper.global_position += -helper.global_transform.basis.z * speed * _delta;

func _on_timer_timeout():
	rotate = deg_to_rad(randf_range(0, 360));
