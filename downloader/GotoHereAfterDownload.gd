extends Node

func _enter_tree() -> void:
	if !Global.goto_after_download:
		Global.goto_after_download = load(owner.scene_file_path);
		# prevent _ready from running
		owner.script = null;
		for node in owner.get_children():
			if node != self:
				node.script = null;
		
		get_tree().change_scene_to_file.call_deferred("res://downloader/DownloadAll.tscn");
