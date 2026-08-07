class_name PFPBall
extends RigidBody2D

@export var bg_hidden := false:
	set(value):
		bg_hidden = value;
		if background:
			background.visible = !bg_hidden;
@export var texture: Texture2D = null:
	set(value):
		texture = value;
		if pfp:
			pfp.texture = value;
@export var grow_when_glowing := true;
# metadata not used by the node itself
@export var index := 0;
@export var entry: LogEntry;

@export var being_dragged := false:
	set(value):
		being_dragged = value;
		mass = 10.0 if being_dragged else 1.0;
		gravity_scale = 0.0 if being_dragged else 1.0;

@onready var clipping_mask: MeshInstance2D = $ClippingMask;
@onready var pfp: TextureRect = $ClippingMask/PFP;
@onready var glow: Sprite2D = $Glow;
@onready var background: ColorRect = $ClippingMask/Background;

func _physics_process(delta: float) -> void:
	clipping_mask.rotation = -rotation;
	
	var target_size := 1.0;
	if glow.visible && grow_when_glowing:
		target_size = 1.4;
	var weight := 1.0 - exp(-16.0 * delta);
	clipping_mask.scale = clipping_mask.scale.lerp(
		Vector2.ONE * target_size, weight
	);
	glow.scale = clipping_mask.scale * 0.7;
