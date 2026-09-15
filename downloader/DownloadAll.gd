extends Control

@export var goto_scene := true;

var downloaders: Array[Downloader] = [];
@onready var console_label: RichTextLabel = $ConsoleLabel;
@onready var loading_label: Label = $LoadingLabel;

var cache_loads: Dictionary[LogEntry, String] = {};

var lines := PackedStringArray();


func _ready() -> void:
	var console_tail := Global.console_log.length();
	console_label.text = "";
	Global.console_changed.connect(func() -> void:
		console_label.text = Global.console_log.right(-console_tail);
	);
	
	for child in get_children():
		if child is Downloader:
			downloaders.append(child);
			child.started_downloading.connect(func() -> void:
				if loading_label:
					loading_label.text = "Downloading missing PFPs...";
			);
			child.make_dir();
	
	loading_label.text = "";
	await get_tree().process_frame;
	
	LogEntry.list.clear();
	LogEntry.altpit.clear();
	var all_entries: Array[LogEntry] = [];
	populate_entry_list("the envies.txt", LogEntry.list, all_entries);
	populate_entry_list("altpit.txt", LogEntry.altpit, all_entries);
	await do_downloads(all_entries);
	
	loading_label.text = "Loading PFPs...";
	while !cache_loads.is_empty():
		await get_tree().process_frame;
	
	Global.print_text("Done loading pfps!");
	if !goto_scene:
		Global.print_text("------");
		Global.print_text("Regular entries: " + str(LogEntry.list.size()));
		Global.print_text("Altpit entries: " + str(LogEntry.altpit.size()));
		await get_tree().process_frame;
		get_tree().quit();
		return;
	if !Global.goto_after_download:
		Global.goto_after_download = load("res://ballpit/Ballpit.tscn");
	get_tree().change_scene_to_packed(Global.goto_after_download);

func populate_entry_list(
	path: String, entries: Array[LogEntry], all_entries: Array[LogEntry] = []
):
	lines = FileAccess.get_file_as_string(path).split("\n");
	for line in lines:
		line = line.strip_edges();
		if line.begins_with("//"):
			continue;
		var entry := LogEntry.parse_log_line(line);
		if !entry:
			continue;
		entry.parse_username_for_downloaders(downloaders);
		entries.append(entry);
		all_entries.append(entry);

func do_downloads(entries: Array[LogEntry]) -> void:
	cache_loads.clear();
	var do_logs := true;
	# log cached and manual images
	var log_all := false;
	
	for entry in entries:
		var downloader := entry.pfp_platform_downloader;
		downloader.target_handle = entry.pfp_platform_handle;
		downloader.download_to = entry.platform_downloader.get_cache_path(
			entry.platform_handle
		);
		
		var cached_path := downloader.get_cached_path();
		if cached_path != "":
			var err := ResourceLoader.load_threaded_request(
				cached_path, "", true
			);
			if err:
				Global.print_err(
					"Failed cache load: " + cached_path + " - " + \
					error_string(err) + " - use Reimport PFPs!"
				);
			if log_all:
				Global.print_text("----CACHED: " + entry.username);
			cache_loads[entry] = cached_path;
			continue;
		
		if do_logs:
			Global.print_text("Fetching: " + entry.username);
		await downloader.do_fetch();
		if do_logs:
			if downloader.pfp_image:
				Global.print_text("----FETCHED: " + entry.username);
			else:
				if downloader.is_manual || downloader.disabled:
					if log_all:
						Global.print_text("---manual: " + entry.username);
				else:
					Global.print_text("----FAIL: " + entry.username);
		entry.texture = ImageTexture.create_from_image(downloader.pfp_image);
		if !downloader.is_manual && !downloader.disabled:
			await get_tree().create_timer(1).timeout;

func _process(_delta: float) -> void:
	for entry in cache_loads.keys():
		var path := cache_loads[entry];
		var status := ResourceLoader.load_threaded_get_status(path);
		match status:
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
				Global.print_err(
					"Failed cache load: " + path + \
					" - THREAD_LOAD_INVALID_RESOURCE - use Reimport PFPs!"
				);
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
				Global.print_err(
					"Failed cache load: " + path + \
					" - THREAD_LOAD_FAILED - use Reimport PFPs!"
				);
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				entry.texture = ResourceLoader.load_threaded_get(path);
				cache_loads.erase(entry);
