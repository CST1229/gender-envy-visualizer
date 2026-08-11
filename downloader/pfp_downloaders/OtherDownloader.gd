extends Downloader

func _fetch_pfp() -> void:
	download_complete.emit(
		null, "Who is " + target_handle + "? Put it in " + get_cache_path()
	);
