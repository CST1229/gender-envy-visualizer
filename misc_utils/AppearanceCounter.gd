extends Node

var people: Dictionary[String, int] = {};
var people_arr: Array[String] = [];

var list := LogEntry.list;

func _ready() -> void:
	Global.print_text("-----");
	Global.print_text("Number of times each person appears in the list:");
	
	for entry in list:
		var username := entry.platform_handle;
		if username not in people:
			people_arr.append(username);
			people[username] = 0;
		people[username] += 1;
	
	people_arr.sort_custom(func(a, b) -> bool:
		return people[a] > people[b];
	);
	
	for person in people_arr:
		if people[person] > 1:
			Global.print_text("%s: %s" % [person, people[person]]);
	Global.print_text("Everyone else: 1");
