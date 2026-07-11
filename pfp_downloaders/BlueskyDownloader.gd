extends Downloader

@onready var http_request: HTTPRequest = $HTTPRequest

func _fetch_pfp() -> void:
	# Handles look like: username.bsky.social
	var url := "https://public.api.bsky.app/xrpc/app.bsky.actor.getProfile?actor=" + target_handle;
	http_request.request_completed.connect(_on_request_completed, ConnectFlags.CONNECT_ONE_SHOT);
	http_request.request(url);

func _on_request_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != OK or response_code != 200:
		download_complete.emit(null, "Failed to fetch profile metadata.");
		return;

	var json = JSON.parse_string(body.get_string_from_utf8());
	if json and json.has("avatar"):
		var avatar_url: String = json["avatar"];
		http_request.request_completed.connect(_on_image_completed, ConnectFlags.CONNECT_ONE_SHOT);
		http_request.request(avatar_url);
	else:
		download_complete.emit(null, "Avatar field missing from Bluesky payload.")

func _on_image_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != OK or response_code != 200:
		download_complete.emit(null, "Failed to download PFP.");
		return;

	load_image(body);

func get_url_for_handle(handle: String) -> String:
	return "https://bsky.app/profile/%s" % handle;
