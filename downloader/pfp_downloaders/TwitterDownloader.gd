extends Downloader

@onready var http_request: HTTPRequest = $HTTPRequest

var opened_links := [];

func _fetch_pfp() -> void:
	var url := "https://twitter.com/" + target_handle + "/photo";
	
	if url not in opened_links:
		OS.shell_open(url);
		opened_links.append(url);
	download_complete.emit(
		null, "Hello, please download the PFP manually from " + url + " and stuff it in " +
		get_cache_path()
	);

func get_url_for_handle(handle: String) -> String:
	return "https://twitter.com/%s" % handle;
