extends Downloader

@onready var http_request: HTTPRequest = $HTTPRequest;

func _ready() -> void:
	http_request.request_completed.connect(_on_image_completed);
	super();

func _fetch_pfp() -> void:
	var url := "https://unavatar.io/x/" + target_handle;
	http_request.request(url);

func _on_image_completed(
	result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray
) -> void:
	if result != OK or response_code != 200:
		download_complete.emit(null, "Failed to download PFP.");
		return;

	load_image(body);

func get_url_for_handle(handle: String) -> String:
	return "https://twitter.com/%s" % handle;
