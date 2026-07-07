extends RigidBody2D

@onready var clipping_mask: MeshInstance2D = $ClippingMask;
@onready var pfp: TextureRect = $ClippingMask/PFP;

func _physics_process(_delta: float) -> void:
	clipping_mask.rotation = -rotation;
