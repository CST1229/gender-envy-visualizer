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


static var line_regex := RegEx.create_from_string(
	r"^([?>#!+\-]*)(.+?-.+?-.+?(?: .+?:.+?)?|\? )\s*-\s*([^#(]+)\s*(\(.+?\))?\s*(#.+)?$"
);
static func parse_log_line(line: String) -> LogEntry:
	var reg_match := line_regex.search(line);
	if !reg_match:
		return null;
	var match_flags := reg_match.strings[1];
	var match_date := reg_match.strings[2];
	var match_username := reg_match.strings[3];
	var match_alt_name := reg_match.strings[4];
	var match_comment := reg_match.strings[5];
	
	var entry := LogEntry.new();
	entry.raw_line = line;
	entry.flags = match_flags.strip_edges();
	entry.is_major = "+" in match_flags;
	entry.is_minor = "?" in match_flags;
	entry.is_friend = "!" in match_flags;
	entry.is_random = "-" in match_flags;
	entry.is_coming_out = ">" in match_flags;
	entry.is_deadname = "#" in match_flags;
	entry.date = match_date.strip_edges();
	entry.username = match_username.strip_edges();
	entry.alt_name = match_alt_name.strip_edges().trim_prefix("(").trim_suffix(")");
	entry.comment = match_comment.strip_edges().trim_prefix("#").strip_edges();
	return entry;

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
