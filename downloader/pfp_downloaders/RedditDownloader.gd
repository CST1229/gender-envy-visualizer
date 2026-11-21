extends Downloader

@onready var http_request: HTTPRequest = $HTTPRequest

var opened_links := [];

func _fetch_pfp() -> void:
	var url := "https://www.reddit.com/user/" + target_handle + "/about.json";
	
	if url not in opened_links:
		OS.shell_open(url);
		opened_links.append(url);
	download_complete.emit(
		null, "Hello, please download the PFP manually from " + url + " and stuff it in " +
		get_cache_path() + " (Make sure to replace `&amp;` with `&`!)"
	);

func get_url_for_handle(handle: String) -> String:
	return "https://www.reddit.com/u/%s" % handle;
