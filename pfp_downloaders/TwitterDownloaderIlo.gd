extends Downloader

@onready var http_request: HTTPRequest = $HTTPRequest;

func _fetch_pfp() -> void:
	var url := "https://ilo.so/api/tools/x/profile/" + target_handle;
	http_request.request_completed.connect(_on_request_completed, ConnectFlags.CONNECT_ONE_SHOT);
	http_request.request(url);

func _on_request_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != OK or response_code != 200:
		download_complete.emit(null, "Failed to reach the API.");
		return;

	var json = JSON.parse_string(body.get_string_from_utf8());
	if json and json.has("profile"):
		var pfp_url: String = json["profile"]["avatar_url"];
		
		# make it full-size
		pfp_url = pfp_url.replace("_normal.jpg", "_200x200.jpg");
		
		http_request.request_completed.connect(_on_image_completed, ConnectFlags.CONNECT_ONE_SHOT);
		http_request.request(pfp_url);
	else:
		print(body.get_string_from_utf8());
		download_complete.emit(null, "Could not extract API response.");

func _on_image_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != OK or response_code != 200:
		download_complete.emit(null, "Failed to download PFP.");
		return;

	load_image(body);
