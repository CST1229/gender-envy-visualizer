extends Node2D

var list := LogEntry.list;

@export var BPM := 144.0;
var BEAT: float:
	get:
		return (60.0 / BPM);
@export var ball_drop_frame_wait := int(floorf(240 * 0.04));
# if 0, uses ball_drop_frame_wait
@export var ball_drop_beat_wait := 0.0;
@export var ball_speed := 16.0;
@export var start_glows_beats := 16.0;
@export var ball_beats := 1.0;
@export var postselect_beats := 8.0;
@export var list_id := "list";

@export var show_all_zoom := 0.55;
@export var show_ball_zoom := 1.5;

@export var gravity_multiplier := 4.0;

@onready var start_pos: Marker2D = $StartPos;
@onready var end_pos: Marker2D = $EndPos;
@onready var cursor: Marker2D = $Cursor;

@onready var person_name: Label = $GUI/PersonName;
@onready var entry_count: Label = $GUI/PersonName/EntryCount;
@onready var camera: Camera2D = $Camera;
@onready var date: Label = $GUI/Date;
@onready var index: Label = $GUI/Index;
@onready var is_friend: Label = $GUI/IsFriend;
@onready var url: Label = $GUI/URL;

@onready var clear_ui_timer: Timer = $ClearUITimer;
@onready var music: AudioStreamPlayer = $Music;

const BALL_DIAMETER := 64.0;
const RANDOM_OFFSET_RANGE := 4.0;
var going_left := false;

var start_tick := 0.0;
var current_ticks := {};


var pfp_ball_scene: PackedScene = load("res://ballpit/objects/PFPBall.tscn");
var balls: Array[PFPBall] = [];

var hovered_ball: PFPBall;

@onready var target_zoom := camera.zoom;

func _ready() -> void:
	list = LogEntry[list_id];
	
	PhysicsServer2D.area_set_param(
		get_viewport().find_world_2d().space,
		PhysicsServer2D.AREA_PARAM_GRAVITY,
		980.0 * gravity_multiplier
	);
	
	var ball_count := 0;
	for entry in list:
		if !entry.image:
			continue;
		ball_count += 1;
	entry_count.text = entry_count.text % ball_count;
	
	person_name.modulate.a = 0;
	var tween := person_name.create_tween();
	tween.tween_property(person_name, "modulate:a", 1.0, 4.0);
	
	date.text = "";
	index.text = "";
	url.text = "";
	is_friend.visible = false;
	
	await get_tree().physics_frame;
	start_tick = Engine.get_physics_frames();
	if music:
		music.play();
	
	var rng := RandomNumberGenerator.new();
	rng.seed = hash("r/egg_irl");
	
	do_glows();
	
	var i := 0;
	cursor.position = start_pos.position;
	for entry in list:
		if !entry.image:
			continue;
		var ball := pfp_ball_scene.instantiate();
		ball.position = cursor.position;
		if going_left:
			ball.position.x += BALL_DIAMETER / 8.0;
		
		# ball.position.x += rng.randfn(0, RANDOM_OFFSET_RANGE);
		# ball.position.y += rng.randfn(0, RANDOM_OFFSET_RANGE);
		
		ball.linear_velocity.y += ball_speed * 60;
		add_child(ball);
		balls.append(ball);
		
		var texture := ImageTexture.create_from_image(entry.image);
		ball.pfp.texture = texture;
		ball.entry = entry;
		ball.z_index = i;
		ball.index = i;
		
		if !going_left && cursor.position.x >= end_pos.position.x:
			going_left = true;
		elif going_left && cursor.position.x <= start_pos.position.x:
			going_left = false;
		else:
			if !going_left:
				cursor.position.x += BALL_DIAMETER;
			else:
				cursor.position.x -= BALL_DIAMETER;
		
		if ball_drop_beat_wait > 0:
			await wait_beats(ball_drop_beat_wait, "ball_drop");
		else:
			for _wait in ball_drop_frame_wait:
				await get_tree().physics_frame;
		i += 1;

func wait_beats(beats: float, thread: String = ""):
	if Input.is_key_pressed(KEY_TAB) || beats <= 0:
		return null;
	
	if thread == "":
		await get_tree().create_timer(BEAT * beats).timeout;
		return;
	
	# complicated sync stuff
	var tick := Engine.get_physics_frames();
	var beat_ticks := (BEAT * beats) * Engine.physics_ticks_per_second;
	if thread not in current_ticks:
		current_ticks[thread] = float(tick) + beat_ticks;
	else:
		current_ticks[thread] += beat_ticks;
	
	while Engine.get_physics_frames() < current_ticks[thread]:
		await get_tree().physics_frame;

func do_glows() -> void:
	camera.zoom = Vector2.ONE;
	target_zoom = Vector2.ONE * show_all_zoom;
	await wait_beats(start_glows_beats, "glows");
	target_zoom = Vector2.ONE * show_ball_zoom;
	entry_count.text = "";
	
	var prev_ball: PFPBall = null;
	for ball in balls:
		highlight_ball(ball);
		camera.position = ball.position;
		camera.position.x *= 0.75;
		
		await wait_beats(ball_beats, "glows");
		prev_ball = ball;
		prev_ball.glow.visible = false;
		prev_ball.z_index = balls.size() + prev_ball.index;
		prev_ball.modulate.v = 0.4;
	
	person_name.text = "";
	camera.position = Vector2.ZERO;
	target_zoom = Vector2.ONE * show_all_zoom;
	date.text = "";
	index.text = "";
	is_friend.visible = false;
	
	for ball in balls:
		var tween := ball.create_tween();
		tween.tween_property(ball, "modulate:v", 1.0, 2.0);
	
	await wait_beats(postselect_beats, "glows");
	
	if OS.has_feature("movie"):
		get_tree().quit();
		return;
	
	clear_ui_timer.timeout.connect(func() -> void:
		for other_ball in balls:
			if other_ball.glow.visible:
				return;
		date.text = "";
		index.text = "";
		person_name.text = "";
		url.text = "";
		is_friend.visible = false;
	);
	for ball in balls:
		ball.input_pickable = true;
		ball.mouse_entered.connect(func() -> void:
			highlight_ball(ball);
			url.text = ball.entry.url;
			hovered_ball = ball;
		);
		ball.mouse_exited.connect(func() -> void:
			ball.glow.visible = false;
			ball.z_index = balls.size() + ball.index;
			
			if hovered_ball == ball:
				hovered_ball = null;
			
			clear_ui_timer.start();
		);

func highlight_ball(ball: PFPBall) -> void:
	person_name.text = ball.entry.nickname;
	is_friend.visible = ball.entry.is_friend;
	if ball.entry.date == "?":
		date.text = ball.entry.username;
	else:
		date.text = ball.entry.date + " - " + ball.entry.username;
	index.text = str("#", ball.index + 1);
	
	ball.glow.visible = true;
	ball.z_index = 4096;

func _input(_event: InputEvent) -> void:
	if _event is not InputEventMouseButton:
		return;
	var event := _event as InputEventMouseButton;
	if event.pressed && event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if hovered_ball && hovered_ball.entry.url:
			OS.shell_open(hovered_ball.entry.url);

func _physics_process(delta: float) -> void:
	var weight := 1.0 - exp(-1.0 * delta);
	camera.zoom = camera.zoom.lerp(target_zoom, weight);
	#index.text = str(Engine.get_frames_per_second());
	#index.visible = true;
