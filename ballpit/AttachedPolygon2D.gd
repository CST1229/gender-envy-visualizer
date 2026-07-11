@tool
extends Polygon2D

func _ready() -> void:
	if "polygon" in get_parent():
		polygon = get_parent().polygon;

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() && "polygon" in get_parent():
		polygon = get_parent().polygon;
