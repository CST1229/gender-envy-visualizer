extends Control

var downloaders: Array[Downloader] = [];
var entries: Array[LogEntry] = LogEntry.list;

var lines := PackedStringArray();
var line_regex := RegEx.create_from_string(
	r"^([?>#!-]*)(.+?-.+?-.+?(?: .+?:.+?)?)\s*-\s*([^#(]+)\s*(\(.+?\))?\s*(#.+)?$"
);

func _ready() -> void:
	entries.clear();
	
	for child in get_children():
		if child is Downloader:
			downloaders.append(child);
			child.make_dir();
	
	lines = FileAccess.get_file_as_string("the envies.txt").split("\n");
	for line in lines:
		var reg_match := line_regex.search(line);
		if reg_match:
			var match_flags := reg_match.strings[1];
			var match_date := reg_match.strings[2];
			var match_username := reg_match.strings[3];
			var match_alt_name := reg_match.strings[4];
			var match_comment := reg_match.strings[5];
			
			var entry := LogEntry.new();
			entry.raw_line = line;
			entry.flags = match_flags.strip_edges();
			entry.is_minor = "?" in match_flags;
			entry.is_friend = "!" in match_flags;
			entry.is_random = "-" in match_flags;
			entry.is_coming_out = ">" in match_flags;
			entry.is_deadname = "#" in match_flags;
			entry.date = match_date.strip_edges();
			entry.username = match_username.strip_edges();
			entry.alt_name = match_alt_name.strip_edges().trim_prefix("(").trim_suffix(")");
			entry.comment = match_comment.strip_edges().trim_prefix("#").strip_edges();
			entry.parse_username_for_downloaders(downloaders);
			
			entries.append(entry);
	
	
	await do_downloads();
	
	print("Done downloading/fetching pfps!");
	get_tree().change_scene_to_file("res://Ballpit.tscn");

func do_downloads() -> void:
	var do_logs := true;
	# log cached and manual images
	var log_all := false;
	
	for entry in entries:
		var downloader := entry.platform_downloader;
		downloader.target_handle = entry.platform_handle;
		
		await downloader.do_fetch();
		if do_logs:
			if downloader.pfp_image:
				if downloader.got_from_cache:
					if log_all:
						prints("----CACHED:", entry.username);
				else:
					prints("----FETCHED:", entry.username);
			else:
				if downloader.is_manual || downloader.disabled:
					if log_all:
						prints("---manual:", entry.username);
				else:
					prints("----FAIL:", entry.username);
		entry.image = downloader.pfp_image;
		if !downloader.is_manual && !downloader.disabled && !downloader.got_from_cache:
			await get_tree().create_timer(1).timeout;
	
