class_name PFPBall
extends RigidBody2D

@export var bg_hidden := false:
	set(value):
		bg_hidden = value;
		if background:
			background.visible = !bg_hidden;
# metadata not used by the node itself
@export var index := 0;
@export var entry: LogEntry;

@onready var clipping_mask: MeshInstance2D = $ClippingMask;
@onready var pfp: TextureRect = $ClippingMask/PFP;
@onready var glow: Sprite2D = $Glow;
@onready var background: ColorRect = $ClippingMask/Background;

func _physics_process(delta: float) -> void:
	clipping_mask.rotation = -rotation;
	
	var target_size := 1.0;
	if glow.visible:
		target_size = 1.4;
	var weight := 1.0 - exp(-16.0 * delta);
	clipping_mask.scale = clipping_mask.scale.lerp(
		Vector2.ONE * target_size, weight
	);
	glow.scale = clipping_mask.scale * 0.7;
