extends Downloader

@onready var http_request: HTTPRequest = $HTTPRequest;

func _fetch_pfp() -> void:
	var url := "https://keep.md/api/twitter-id";
	http_request.request_completed.connect(_on_request_completed, ConnectFlags.CONNECT_ONE_SHOT);
	http_request.request(url, [
		"Referer: https://keep.md/tools/twitter-profile-picture-downloader/",
		"User-Agent: CST1229's thingy, contact: cst1229@outlook.com"
	], HTTPClient.METHOD_POST, JSON.stringify({"username": target_handle}));

func _on_request_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	var body_string := body.get_string_from_utf8();
	if result != OK or response_code != 200:
		Global.print_text(body_string);
		download_complete.emit(null, "Failed to reach the API. " + str(response_code));
		return;

	var json = JSON.parse_string(body_string);
	if json and json.has("error") && json["error"]:
		Global.print_text(body_string);
		download_complete.emit(null, "API returned error.");
	elif json and json.has("user"):
		var pfp_url: String = json["user"]["avatar_url"];
		
		# make it full-size
		pfp_url = pfp_url.replace("_normal.jpg", "_200x200.jpg");
		
		http_request.request_completed.connect(_on_image_completed, ConnectFlags.CONNECT_ONE_SHOT);
		http_request.request(pfp_url);
	else:
		Global.print_text(body_string);
		download_complete.emit(null, "Could not extract API response.");

func _on_image_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != OK or response_code != 200:
		download_complete.emit(null, "Failed to download PFP.");
		return;

	load_image(body);

func get_url_for_handle(handle: String) -> String:
	return "https://twitter.com/%s" % handle;
