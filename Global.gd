extends Node

var console_log := "...Is it cis to make such an intricate project for *gender envy*?  -CST1229\
\n\nThis is the console log.\nStuff will go here.\n\n";
var mute := false;

var coming_from_menu := false;
var goto_after_download: PackedScene;

var base_tickrate: int = ProjectSettings.get_setting("physics/common/physics_ticks_per_second");
const FFWD_RATE = 3;

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
			var old_mode := window.mode;
			window.msaa_2d = Viewport.MSAA_4X;
			window.mode = Window.MODE_WINDOWED;
			window.size *= 3.0;
			await RenderingServer.frame_post_draw;
			window.get_texture().get_image().save_png("media/hires_screenshot.png");
			window.size = old_size;
			window.msaa_2d = Viewport.MSAA_DISABLED;
			window.mode = old_mode;
			Global.print_text("Took hi-res screenshot!");
		elif keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://Menu.tscn");
		elif keycode == KEY_F10 || keycode == KEY_M:
			mute = !mute;
			mute_changed.emit();
		elif keycode == KEY_RIGHT:
			Engine.physics_ticks_per_second = base_tickrate * FFWD_RATE;
			Engine.time_scale = FFWD_RATE;
	elif ev is InputEventKey && !ev.is_echo() && ev.is_released():
		var keycode := (ev as InputEventKey).keycode;
		if keycode == KEY_RIGHT:
			Engine.physics_ticks_per_second = base_tickrate;
			Engine.time_scale = 1.0;

func print_text(string: String) -> void:
	print(string);
	console_log += string + "\n";
	
func print_err(string: String) -> void:
	printerr(string);
	console_log += "ERR: " + string + "\n";

signal mute_changed;
