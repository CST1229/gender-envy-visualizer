extends Node2D

@onready var start_pos: Marker2D = $StartPos;
@onready var end_pos: Marker2D = $EndPos;
@onready var cursor: Marker2D = $Cursor;

const BALL_DIAMETER := 64.0;
const RANDOM_OFFSET_RADIUS := 8.0;
var going_left := false;

var PFPBall: PackedScene = load("res://PFPBall.tscn");

func _ready() -> void:
	var rng := RandomNumberGenerator.new();
	rng.seed = hash("r/egg_irl");
	
	cursor.position = start_pos.position;
	for entry in LogEntry.list:
		if !entry.image:
			continue;
		var ball := PFPBall.instantiate();
		ball.position = cursor.position;
		
		var random_offset := 0.0;
		if cursor.position.x == 0:
			random_offset = rng.randf_range(
				-RANDOM_OFFSET_RADIUS, RANDOM_OFFSET_RADIUS
			);
		elif cursor.position.x > 0:
			random_offset = rng.randf_range(
				-RANDOM_OFFSET_RADIUS, 0
			);
		else:
			random_offset = rng.randf_range(
				0, RANDOM_OFFSET_RADIUS
			);
		ball.position.x += random_offset;
		
		ball.linear_velocity.y += 32 * 60;
		add_child(ball);
		
		var texture := ImageTexture.create_from_image(entry.image);
		ball.pfp.texture = texture;
		
		if !going_left && cursor.position.x >= end_pos.position.x:
			going_left = true;
		elif going_left && cursor.position.x <= start_pos.position.x:
			going_left = false;
		else:
			if !going_left:
				cursor.position.x += BALL_DIAMETER;
			else:
				cursor.position.x -= BALL_DIAMETER;
		
		await get_tree().create_timer(0.1).timeout;
