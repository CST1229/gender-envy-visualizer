extends Control

@onready var main: Button = $HBoxContainer/VBoxContainer/Main;
@onready var altpit: Button = $HBoxContainer/VBoxContainer/Altpit;
@onready var combined: Button = $HBoxContainer/VBoxContainer/Combined;
@onready var download: Button = $HBoxContainer/VBoxContainer/Download;
@onready var stats: Button = $HBoxContainer/VBoxContainer/Stats;
@onready var list_status: Label = $HBoxContainer/VBoxContainer/ListStatus;
@onready var mute: Button = $HBoxContainer/VBoxContainer/MuteHints/Mute;
@onready var hints: Button = $HBoxContainer/VBoxContainer/MuteHints/Hints;

@onready var console_log: RichTextLabel = $HBoxContainer/ConsoleLog;

func _ready() -> void:
	update_console();
	
	Global.coming_from_menu = true;
	main.pressed.connect(func() -> void:
		await loading_text();
		get_tree().change_scene_to_file("res://ballpit/BallpitAltMusicNew.tscn");
	);
	altpit.pressed.connect(func() -> void:
		await loading_text();
		get_tree().change_scene_to_file("res://ballpit/Altpit.tscn");
	);
	combined.pressed.connect(func() -> void:
		await loading_text();
		get_tree().change_scene_to_file("res://ballpit/CombinedBallpit.tscn");
	);
	download.pressed.connect(func() -> void:
		await loading_text(true);
		Global.goto_after_download = load("res://Menu.tscn");
		get_tree().change_scene_to_file("res://downloader/DownloadAll.tscn");
	);
	stats.pressed.connect(func() -> void:
		await loading_text();
		get_tree().change_scene_to_file("res://misc_utils/Stats.tscn");
	);
	hints.pressed.connect(func() -> void:
		p("----- Global keybinds:");
		p("ESC: return to menu");
		p("F2: take hi-res screenshot, stored in media/hires_screenshot.png");
		p("F11: toggle fullscreen");
		p("M or F10: toggle mute");
		p("----- Keybinds on this menu:");
		p("F6: clear logs");
		p("Ctrl+C: copy logs");
		p("----- Ballpit keybinds:");
		p("TAB: skip ball highlights");
		p("Right Arrow: fastforward (may cause minor instability)");
		p("-- After camera zooms back out:");
		p("Mouse: hover over balls, click to open URL (if a ball has one)");
		p("D: toggle drag mode (use mouse)");
		p("C: summon CST1229");
		p("-----");
		
		update_console();
	);
	
	if LogEntry.list && LogEntry.list.size() > 0:
		list_status.text = "Log entries: %s\n\
Altpit entries: %s" % [LogEntry.list.size(), LogEntry.altpit.size()];
	mute.pressed.connect(func() -> void:
		Global.mute = !Global.mute;
		Global.mute_changed.emit();
	);
	Global.mute_changed.connect(func() -> void:
		mute.text = "Mute: OFF" if !Global.mute else "Mute: ON";
	);
	mute.text = "Mute: OFF" if !Global.mute else "Mute: ON";

func update_console() -> void:
	console_log.text = Global.console_log;
	console_log.scroll_to_paragraph(INT32_MAX);
	await get_tree().process_frame;
	console_log.scroll_to_paragraph(INT32_MAX);

func loading_text(force := false) -> void:
	if LogEntry.list && LogEntry.list.size() > 0 && !force:
		return;
	console_log.text += "Loading...\n";
	console_log.scroll_to_paragraph(INT32_MAX);
	await get_tree().process_frame;
	await get_tree().process_frame;

func p(string: String) -> void:
	Global.print_text(string);

func _input(ev: InputEvent) -> void:
	if ev is InputEventKey && !ev.is_echo() && ev.is_pressed():
		var keycode := (ev as InputEventKey).keycode;
		if keycode == KEY_F6:
			Global.console_log = "";
			update_console();
		elif keycode == KEY_C:
			if (ev as InputEventKey).ctrl_pressed:
				DisplayServer.clipboard_set(Global.console_log);
