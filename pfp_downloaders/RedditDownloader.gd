extends Downloader

@onready var http_request: HTTPRequest = $HTTPRequest

var headers := ["User-Agent: CSTsPFPFetcher/1.0 (by /u/CST1230)"];

func _fetch_pfp() -> void:
	var url := "https://www.reddit.com/user/" + target_handle + "/about.json";
	
	OS.shell_open(url);
	download_complete.emit(
		null, "Hello, please download the PFP manually from " + url + " and stuff it in " +
		get_cache_path()
	);

func _on_request_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	var file := FileAccess.open("response.html", FileAccess.WRITE);
	file.store_buffer(body);
	if result != OK or response_code != 200:
		print("ua: ", headers[0]);
		print("url: ", "https://www.reddit.com/user/" + target_handle + "/about.json");
		download_complete.emit(null, "Reddit request failed. Code: " + str(response_code));
		return;
	var json = JSON.parse_string(body.get_string_from_utf8());
	if json and json.has("data") and json["data"].has("icon_img"):
		var clean_url: String = json["data"]["icon_img"].replace("&amp;", "&");
		
		http_request.request_completed.connect(_on_image_completed, ConnectFlags.CONNECT_ONE_SHOT);
		http_request.request(clean_url, headers);
	else:
		download_complete.emit(null, "User info or icon_img not found in Reddit JSON.");

func _on_image_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != OK or response_code != 200:
		download_complete.emit(null, "Failed to download PFP.");
		return;

	load_image(body);
