extends Downloader

@onready var http_request: HTTPRequest = $HTTPRequest;

func _ready() -> void:
	http_request.request_completed.connect(_on_image_completed);
	super();

func _fetch_pfp() -> void:
	var handle := target_handle.to_lower();
	var url := "https://a.deviantart.net/avatars-big/%s/%s/%s.jpg" % [
		handle[0], handle[1], handle
	];
	http_request.request(url);

func _on_image_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != OK or response_code != 200:
		download_complete.emit(null, "Failed to download PFP.");
		return;

	load_image(body);

func get_url_for_handle(handle: String) -> String:
	return "https://www.deviantart.com/%s" % handle;
