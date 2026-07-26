extends Node2D

func _ready() -> void:
	print("-----");
	print("Done collecting stats!");
	await get_tree().physics_frame;
	await get_tree().physics_frame;
	get_tree().quit();
