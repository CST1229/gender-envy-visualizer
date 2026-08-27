extends Node

var times: Dictionary[String, int] = {};
var majors: Dictionary[String, int] = {};
const TOTAL = "Total entries";

var list := LogEntry.list;

func _ready() -> void:
	Global.print_text("-----");
	Global.print_text("Number of times each platform appears in the list:");
	
	times[TOTAL] = 0;
	majors[TOTAL] = 0;
	for entry in list:
		var id := entry.platform_id;
		if id not in times:
			times[id] = 0;
		if id not in majors:
			majors[id] = 0;
		times[id] += 1;
		times[TOTAL] += 1;
		if entry.is_major:
			majors[id] += 1;
			majors[TOTAL] += 1;
	
	var times_arr := times.keys();
	times_arr.sort_custom(func(a, b) -> bool:
		return times[a] > times[b];
	);
	for id in times_arr:
		Global.print_text("%s: %s (%.2f%%)" % [
			id, times[id], times[id] / float(times[TOTAL]) * 100.0
		]);
	
	Global.print_text("-----");
	Global.print_text("Percentage of major hits per platform, relative to platform hit count:");
	
	var majors_arr := times.keys();
	majors_arr.sort_custom(func(a, b) -> bool:
		return (majors[a] / float(times[a])) > (majors[b] / float(times[b]));
	);
	for id in majors_arr:
		Global.print_text("%s: %.2f%% (%s hits)" % [
			id, majors[id] / float(times[id]) * 100.0, majors[id]
		]);
	
