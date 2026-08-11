extends Downloader

@onready var yt_page_request: HTTPRequest = $YTPageRequest;
@onready var image_request: HTTPRequest = $ImageRequest;

var headers := ["User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"];

func _ready() -> void:
	yt_page_request.request_completed.connect(_on_page_request_completed);
	image_request.request_completed.connect(_on_image_request_completed);
	
	super();

func _fetch_pfp() -> void:
	var url := "https://www.youtube.com/@" + target_handle;
	yt_page_request.request(url, headers);

func _on_page_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if result != OK:
		download_complete.emit(
			null, "Failed to fetch YouTube page. Result code: " + error_string(result)
			);
		return
	if response_code != 200:
		download_complete.emit(
			null, "failed to fetch youtube page. Response code: " + str(response_code)
		);
		print(body.get_string_from_utf8());
		return
		
	var html := body.get_string_from_utf8();
	
	var regex := RegEx.new();
	regex.compile('<meta property="og:image" content="([^"]+)">');
	
	var match_result := regex.search(html);
	if match_result:
		var pfp_url := match_result.get_string(1);
		
		image_request.request(pfp_url, headers);
	else:
		download_complete.emit(null, "could not find profile picture meta tag in html");

func _on_image_request_completed(
	result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	if result != OK or response_code != 200:
		download_complete.emit(null, "Failed to download PFP.");
		return;
	
	load_image(body);

func get_url_for_handle(handle: String) -> String:
	return "https://youtube.com/@%s" % handle;
