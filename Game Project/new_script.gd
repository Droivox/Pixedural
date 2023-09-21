extends Node
func _ready(): setup();
func _process(_delta): loop();

var time = 3;

func setup():
	while time > 0:
		serialPrint(time);
		time -= 1;

func loop():
	pass


func serialPrint(text):
	print(text);
