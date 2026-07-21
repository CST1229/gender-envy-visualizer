extends Node

var goto_after_download: PackedScene;

func _input(ev: InputEvent) -> void:
	if ev is InputEventKey && !ev.is_echo() && ev.is_pressed() && (
		ev as InputEventKey
	).keycode == KEY_F11:
		if get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
			get_window().mode = Window.MODE_MAXIMIZED;
		else:
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN;
