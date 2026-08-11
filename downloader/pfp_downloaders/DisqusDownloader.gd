extends Downloader

@onready var http_request: HTTPRequest = $HTTPRequest;

func _ready() -> void:
	_fetch_pfp();
	super();

func _fetch_pfp() -> void:
	var url := "https://disqus.com/api/users/avatars/" + target_handle + ".jpg";
	http_request.request_completed.connect(_on_redirect_completed, ConnectFlags.CONNECT_ONE_SHOT);
	http_request.request(url);

func _on_redirect_completed(
	result: int, response_code: int, headers: PackedStringArray, _body: PackedByteArray
) -> void:
	if result != ERR_FILE_CANT_OPEN || response_code != 302:
		print(error_string(result));
		print(response_code);
		download_complete.emit(null, "Failed to download PFP.");
		return;
	
	var url := "";
	for header in headers:
		if header.begins_with("Location: "):
			url = header.trim_prefix("Location: ");
			break;
	if url == "":
		download_complete.emit(null, "Failed to download PFP.");
		return;
	
	url = url.replace("avatar92.jpg", "avatar200.jpg");
	http_request.request_completed.connect(_on_image_completed, ConnectFlags.CONNECT_ONE_SHOT);
	http_request.request(url);
	
	
func _on_image_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != OK or response_code != 200:
		download_complete.emit(null, "Failed to download PFP.");
		return;

	load_image(body);

func get_url_for_handle(handle: String) -> String:
	return "https://disqus.com/by/%s" % handle;
