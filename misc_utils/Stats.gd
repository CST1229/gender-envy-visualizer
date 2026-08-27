extends Node2D

func _ready() -> void:
	Global.print_text("-----");
	Global.print_text("Done collecting stats!");
	Global.print_text("%s total entries" % LogEntry.list.size());
	await get_tree().physics_frame;
	await get_tree().physics_frame;
	if !Global.coming_from_menu:
		get_tree().quit();
	else:
		get_tree().change_scene_to_file("res://Menu.tscn");
