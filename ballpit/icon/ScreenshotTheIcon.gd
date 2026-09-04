extends SubViewport

func _ready() -> void:
	await RenderingServer.frame_post_draw;
	var texture := get_texture();
	var image := texture.get_image();
	image.save_png("res://icon.png");
