class_name LogEntry
extends Resource

static var list: Array[LogEntry] = [];
static var altpit: Array[LogEntry] = [];

var raw_line := "";

var flags := "";
var is_major := false;
var is_minor := false;
var is_friend := false;
var is_random := false;
var is_coming_out := false;
var is_deadname := false;

var date := "";
var username := "";
var alt_name := "";
var comment := "";

var image: Image;

var platform_id := "";
var platform_handle := "";
var platform_downloader: Downloader;

var nickname: String:
	get:
		if alt_name:
			return alt_name;
		return platform_handle \
			.trim_prefix("dsc@").trim_suffix(".bsky.social");

var url := "";

func parse_username_for_downloaders(downloaders: Array[Downloader]) -> void:
	platform_handle = "";
	platform_id = "";
	platform_downloader = null;
	for downloader in downloaders:
		if downloader.special_prefix == "*":
			platform_handle = username.trim_prefix("https://");
		elif downloader.special_prefix != "":
			if username.begins_with(downloader.special_prefix):
				platform_handle = username.trim_prefix(downloader.special_prefix);
		else:
			if username.begins_with(downloader.platform_id + "@"):
				platform_handle = username.trim_prefix(downloader.platform_id + "@");
		if platform_handle != "":
			platform_id = downloader.platform_id;
			platform_downloader = downloader;
			url = downloader.get_url_for_handle(platform_handle);
			break;
