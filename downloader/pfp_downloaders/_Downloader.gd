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
var got_from_cache := false;

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
			#if !got_from_cache:
				#Global.print_text(
					#"Successfully loaded online PFP for " + platform_id +
					#" handle " + target_handle + "!"
				#);
			#else:
				#Global.print_text(
					#"Successfully loaded cached PFP for " + platform_id +
					#" handle " + target_handle + "!"
				#);
		
		download_done.emit();
	, ConnectFlags.CONNECT_DEFERRED);

func do_fetch() -> void:
	pfp_image = null;
	got_from_cache = false;
	error_msg = "Loading...";
	
	var cache_path := get_cache_path() if download_to == "" else download_to;
	var cache_path_jpeg := cache_path.get_basename() + ".jpeg";
	make_dir();
	if fetch_pfp_from_cache(cache_path, "load_png_from_buffer"):
		pass
	elif fetch_pfp_from_cache(cache_path_jpeg, "load_jpg_from_buffer"):
		pass
	else:
		if disabled:
			download_complete.emit(
				null, "Who is " + target_handle + "? Put it in " + get_cache_path()
			);
		else:
			started_downloading.emit();
			_fetch_pfp();
	await download_done;
	
	if pfp_image && !got_from_cache:
		LogEntry.pfp_cache[cache_path] = pfp_image;
		pfp_image.save_png(cache_path);

func fetch_pfp_from_cache(cache_path: String, method_name: String) -> bool:
	if !FileAccess.file_exists(cache_path):
		return false;
	if cache_path in LogEntry.pfp_cache:
		error_msg = "";
		pfp_image = LogEntry.pfp_cache[cache_path];
		got_from_cache = true;
		download_complete.emit(pfp_image, error_msg);
		return true;
	error_msg = "";
	pfp_image = Image.new();
	got_from_cache = true;
	var error: Error = pfp_image.call(
		method_name,
		FileAccess.get_file_as_bytes(cache_path)
	);
	if error != OK:
		pfp_image = null;
		error_msg = "Failed to load cached PFP image: " + error_string(error);
	download_complete.emit(pfp_image, error_msg);
	return true;

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
