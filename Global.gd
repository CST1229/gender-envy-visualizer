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
	elif ev is InputEventKey && !ev.is_echo() && ev.is_pressed() && (
		ev as InputEventKey
	).keycode == KEY_F2:
		var window := get_window();
		var old_size := window.size;
		window.msaa_2d = Viewport.MSAA_4X;
		window.mode = Window.MODE_WINDOWED;
		window.size *= 3.0;
		await RenderingServer.frame_post_draw;
		window.get_texture().get_image().save_png("media/hires_screenshot.png");
		window.size = old_size;
		window.msaa_2d = Viewport.MSAA_DISABLED;
		print("Took hi-res screenshot!");
