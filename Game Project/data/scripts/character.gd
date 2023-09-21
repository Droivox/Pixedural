extends CharacterBody3D

@export var noclip : bool = false;
@export var speed : float = 4.0;
const ACCELERATION : float = 8.0;

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");
var jumpHeight : float = 6.0;

var input : Dictionary;

func _ready() -> void:
	inputs();

func _process(_delta) -> void:
	inputs();

func inputs() -> void:
	input["left"]    = int(Input.is_action_pressed("KEY_A"));
	input["right"]   = int(Input.is_action_pressed("KEY_D"));
	input["forward"] = int(Input.is_action_pressed("KEY_W"));
	input["back"]    = int(Input.is_action_pressed("KEY_S"));
	input["sprint"]  = int(Input.is_action_pressed("KEY_SHIFT"));
	input["jump"]    = int(Input.is_action_pressed("KEY_SPACE"));

func _physics_process(_delta) -> void:
	if Input.is_action_just_pressed("KEY_CAPSLOCK"):
		noclip = !noclip;
	
	if noclip:
		movementNoClip(_delta);
		$CollisionShape3D.disabled = true;
	else:
		movement(_delta);
		$CollisionShape3D.disabled = false;

func movementNoClip(_delta) -> void:
	var direction = Vector3();
	
	var bs = get_viewport().get_camera_3d().global_transform.basis;
	direction += (-input["left"]    + input["right"]) * bs.x;
	direction += (-input["forward"]  +  input["back"]) * bs.z;
	
	direction = direction.normalized();
	var target = direction * speed * 4;
	
	velocity.x = lerp(velocity.x, target.x, ACCELERATION * _delta);
	velocity.z = lerp(velocity.z, target.z, ACCELERATION * _delta);
	velocity.y = lerp(velocity.y, target.y, ACCELERATION * _delta);
	
	if input["sprint"]:
		speed = 10.0;
	else:
		speed = 4.0;
	
	move_and_slide();

func movement(_delta) -> void:
	var direction = Vector3();
	
	var bs = get_viewport().get_camera_3d().global_transform.basis;
	direction += (-input["left"]    + input["right"]) * bs.x;
	direction += (-input["forward"]  +  input["back"]) * bs.z;
	
	direction.y = 0; direction = direction.normalized();
	var target = direction * speed;
	
	if not is_on_floor():
		velocity.y -= (gravity * 2.0) * _delta;
	else:
		if input["jump"]:
				velocity.y = jumpHeight
	
	velocity.x = lerp(velocity.x, target.x, ACCELERATION * _delta);
	velocity.z = lerp(velocity.z, target.z, ACCELERATION * _delta);
	
	move_and_slide();
