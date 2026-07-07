class_name Downloader
extends Node

@export var disabled := false;
@export var target_handle: String = "CST1229";

@export var platform_id: String = "";
@export var special_prefix: String = "";
@export var is_manual := false;

var error_msg := "";
var pfp_image: Image;
var got_from_cache := false;

func _ready() -> void:
	download_complete.connect(func(image: Image, res: String) -> void:
		error_msg = res;
		pfp_image = image;
		if !image:
			printerr(
				platform_id + ": " +
				res
			);
		else:
			pass
			#if !got_from_cache:
				#print(
					#"Successfully loaded online PFP for " + platform_id +
					#" handle " + target_handle + "!"
				#);
			#else:
				#print(
					#"Successfully loaded cached PFP for " + platform_id +
					#" handle " + target_handle + "!"
				#);
		
		download_done.emit();
	, ConnectFlags.CONNECT_DEFERRED);

func do_fetch() -> void:
	pfp_image = null;
	got_from_cache = false;
	error_msg = "Loading...";
	
	var cache_path := get_cache_path();
	make_dir();
	if FileAccess.file_exists(cache_path):
		error_msg = "";
		pfp_image = Image.new();
		got_from_cache = true;
		var error := pfp_image.load_png_from_buffer(FileAccess.get_file_as_bytes(cache_path));
		if error != OK:
			pfp_image = null;
			error_msg = "Failed to load cached PFP image: " + error_string(error);
		download_complete.emit(pfp_image, error_msg);
	else:
		if disabled:
			download_complete.emit(
				null, "Who is " + target_handle + "? Put it in " + get_cache_path()
			);
		else:
			_fetch_pfp();
	await download_done;
	
	if pfp_image && !got_from_cache:
		pfp_image.save_png(cache_path);

func _fetch_pfp() -> void:
	download_complete.emit(null, "Not implemented");

func get_cache_path() -> String:
	return "pfp_cache/" + platform_id + "/" + target_handle + ".png";

func load_image(body: PackedByteArray, image = Image.new()) -> void:
	if image.load_png_from_buffer(body) == OK or image.load_jpg_from_buffer(body) == OK \
		or image.load_webp_from_buffer(body) == OK:
		download_complete.emit(image, "");
	else:
		download_complete.emit(null, "Failed to parse image data.");

func make_dir() -> void:
	DirAccess.make_dir_absolute(get_cache_path().get_base_dir());

signal download_complete(image: Image, msg: String);
signal download_done();
