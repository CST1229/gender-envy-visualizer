extends Node

var console_log := "This is the console log.\nStuff will go here.\n\n";
var mute := false;

var coming_from_menu := false;
var goto_after_download: PackedScene;

func _input(ev: InputEvent) -> void:
	if ev is InputEventKey && !ev.is_echo() && ev.is_pressed():
		var keycode := (ev as InputEventKey).keycode;
		if keycode == KEY_F11:
			if get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
				get_window().mode = Window.MODE_MAXIMIZED;
			else:
				get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN;
		elif keycode == KEY_F2:
			var window := get_window();
			var old_size := window.size;
			window.msaa_2d = Viewport.MSAA_4X;
			window.mode = Window.MODE_WINDOWED;
			window.size *= 3.0;
			await RenderingServer.frame_post_draw;
			window.get_texture().get_image().save_png("media/hires_screenshot.png");
			window.size = old_size;
			window.msaa_2d = Viewport.MSAA_DISABLED;
			Global.print_text("Took hi-res screenshot!");
		elif keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://Menu.tscn");
		elif keycode == KEY_F10 || keycode == KEY_M:
			mute = !mute;
			mute_changed.emit();
func print_text(string: String) -> void:
	print(string);
	console_log += string + "\n";
	
func print_err(string: String) -> void:
	printerr(string);
	console_log += "ERR: " + string + "\n";

signal mute_changed;
