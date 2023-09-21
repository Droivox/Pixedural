extends Camera3D

@export var speed : int = 5;
@export var maxAngle : int = 85;
@export var sensitivity : float = 0.2;

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func _process(_delta) -> void:
	if Input.is_action_just_pressed("KEY_ESCAPE"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func cameraRotation(_event) -> void:
	if _event is InputEventMouseMotion:
		rotation.x += -deg_to_rad(_event.relative.y * sensitivity);
		rotation.y += -deg_to_rad(_event.relative.x * sensitivity);
	
	rotation.x = min(rotation.x,  deg_to_rad(maxAngle))
	rotation.x = max(rotation.x, -deg_to_rad(maxAngle))
	
func _input(_event) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		cameraRotation(_event);
