@tool
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
			if !value && Engine.is_editor_hint():
				pfp.texture = load("res://ballpit/assets/godot_icon.svg");
@export var grow_when_glowing := true;
# metadata not used by the node itself
@export var index := 0;
@export var entry: LogEntry;

# you can use this if your texture is already a ball
@export var disable_clipping := false:
	set(value):
		disable_clipping = value;
		if clipping_mask:
			clipping_mask.clip_children = \
				CanvasItem.CLIP_CHILDREN_DISABLED if disable_clipping \
				else CanvasItem.CLIP_CHILDREN_ONLY;
			if disable_clipping:
				clipping_mask.self_modulate = Color.TRANSPARENT;
			else:
				clipping_mask.self_modulate = Color.WHITE;

@export var being_dragged := false:
	set(value):
		being_dragged = value;
		mass = 10.0 if being_dragged else 1.0;
		gravity_scale = 0.0 if being_dragged else 1.0;

@onready var clipping_mask: MeshInstance2D = $ClippingMask;
@onready var pfp: TextureRect = $ClippingMask/PFP;
@onready var glow: Sprite2D = $Glow;
@onready var background: ColorRect = $ClippingMask/Background;

func _ready() -> void:
	bg_hidden = bg_hidden;
	texture = texture;
	disable_clipping = disable_clipping;

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return;
	clipping_mask.rotation = -rotation;
	
	var target_size := 1.0;
	if glow.visible && grow_when_glowing:
		target_size = 1.4;
	var weight := 1.0 - exp(-16.0 * delta);
	clipping_mask.scale = clipping_mask.scale.lerp(
		Vector2.ONE * target_size, weight
	);
	glow.scale = clipping_mask.scale * 0.7;
	if position.y > 2500:
		visible = false;
		process_mode = Node.PROCESS_MODE_DISABLED;
