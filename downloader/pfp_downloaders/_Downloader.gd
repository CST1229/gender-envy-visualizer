class_name Downloader
extends Node

@export var disabled := false;
@export var target_handle: String = "CST1229";
@export var download_to := "";

@export var platform_id: String = "";
@export var special_prefix: String = "";
@export var is_manual := false;

var error_msg := "";
var pfp_image: Image;

func _ready() -> void:
	download_complete.connect(func(image: Image, res: String) -> void:
		error_msg = res;
		pfp_image = image;
		if !image:
			Global.print_err(
				platform_id + ": " + res
			);
		else:
			pass
		
		download_done.emit();
	, ConnectFlags.CONNECT_DEFERRED);

func do_fetch() -> void:
	pfp_image = null;
	error_msg = "Loading...";
	
	var cache_path := get_cache_path() if download_to == "" else download_to;
	make_dir();
	if disabled:
		download_complete.emit(
			null, "Who is " + target_handle + "? Put it in " + get_cache_path()
		);
	elif !OS.has_feature("editor") || OS.has_feature("web"):
		started_downloading.emit();
		download_complete.emit(
			null, "Can't download PFPs in exported builds"
		);
	else:
		started_downloading.emit();
		_fetch_pfp();
	await download_done;
	
	if pfp_image:
		LogEntry.pfp_cache[cache_path] = pfp_image;
		pfp_image.save_png(cache_path);

func get_cached_path() -> String:
	var cache_path := get_cache_path() if download_to == "" else download_to;
	var cache_path_jpeg := cache_path.get_basename() + ".jpeg";
	if FileAccess.file_exists(cache_path + ".import"):
		return cache_path;
	elif FileAccess.file_exists(cache_path_jpeg + ".import"):
		return cache_path_jpeg;
	elif FileAccess.file_exists(cache_path):
		Global.print_err("Cached PFP file not imported! Use Reimport PFPs! " + cache_path);
	elif FileAccess.file_exists(cache_path_jpeg):
		Global.print_err("Cached PFP file not imported! Use Reimport PFPs! " + cache_path_jpeg);
	return "";

func _fetch_pfp() -> void:
	download_complete.emit(null, "Not implemented");

func get_cache_path(handle := target_handle) -> String:
	return "pfp_cache/" + platform_id + "/" + handle + ".png";

func load_image(body: PackedByteArray, image = Image.new()) -> void:
	if image.load_png_from_buffer(body) == OK or image.load_jpg_from_buffer(body) == OK \
		or image.load_webp_from_buffer(body) == OK:
		download_complete.emit(image, "");
	else:
		download_complete.emit(null, "Failed to parse image data.");

func make_dir() -> void:
	DirAccess.make_dir_absolute(get_cache_path().get_base_dir());

## Returns a user-visitable page URL, not a PFP URL.
func get_url_for_handle(_handle: String) -> String:
	return "";

signal started_downloading();
signal download_complete(image: Image, msg: String);
signal download_done();
