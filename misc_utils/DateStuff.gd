extends Node

var times: Dictionary[String, int] = {};
var weekdays: Dictionary[String, int] = {};
var hours: Dictionary[String, int] = {};

var list := LogEntry.list;

# agggh sunday at 0
const days_of_week = [
	"Sunday", "Monday", "Tuesday", "Wednesday",
	"Thursday", "Friday", "Saturday", "Unknown date"
];
const days_of_week_actual = [
	"Monday", "Tuesday", "Wednesday", "Thursday",
	"Friday", "Saturday", "Sunday", "Unknown date"
];

func _ready() -> void:
	for entry in list:
		var is_unknown_date := false;
		var is_unknown_time := false;
		
		var datetime := entry.date;
		if datetime.length() <= "0000-00-00".length():
			datetime += " 0:00";
			is_unknown_time = true;
		# add seconds since those are never recorded
		datetime = datetime + ":00";
		if "?:?" in datetime:
			is_unknown_time = true;
		var date_dict := Time.get_datetime_dict_from_datetime_string(
			datetime.replace("?", "1"), true
		);
		var date := "%04d-%02d-%02d" % [
			date_dict["year"], date_dict["month"], date_dict["day"]
		];
		if date == "20211-11-11":
			date = "2021-??-??";
			is_unknown_date = true;
			
		times[date] = times.get(date, 0) + 1;
		var wd := str(days_of_week[int(date_dict["weekday"])]);
		if is_unknown_date:
			wd = "Unknown date";
		weekdays[wd] = weekdays.get(wd, 0) + 1;
		var hr := str(date_dict["hour"]);
		if is_unknown_time:
			hr = "Unknown time";
		hours[hr] = hours.get(hr, 0) + 1;
		
		if !is_unknown_date:
			entry.set_meta(&"unix_time", Time.get_unix_time_from_datetime_dict(date_dict));
	
	print("-----");
	print("Number of hits per day:");
	var times_arr := times.keys();
	#times_arr.sort_custom(func(a, b) -> bool:
		#return times[a] > times[b];
	#);
	for date in times_arr:
		print("%s: %s" % [date, times[date]]);
	
	print("-----");
	print("Number of hits per day of week:");
	var weekdays_arr := weekdays.keys();
	weekdays_arr.sort_custom(func(a, b) -> bool:
		return weekdays[a] > weekdays[b];
	);
	for wd in days_of_week_actual:
		print("%s: %s" % [wd, weekdays[wd]]);
	
	print("-----");
	print("Number of hits per hour of day:");
	for i in range(0, 24):
		hours[str(i)] = hours.get(str(i), 0);
	var hours_arr := hours.keys();
	hours_arr.sort_custom(func(a, b) -> bool:
		return str(a).naturalnocasecmp_to(b) < 0;
	);
	for hour in hours_arr:
		print("%s: %s" % [hour, hours[hour]]);
	
	print("-----");
	print("Biggest gap between hits (except retroactive hits):");
	
	var biggestgap_a: LogEntry = null;
	var biggestgap_b: LogEntry = null;
	var biggestgap_time := 0;
	var prev: LogEntry = null;
	for entry in list:
		if !entry.has_meta(&"unix_time"):
			continue;
		if entry.is_retroactive:
			continue;
		if prev:
			var time := int(entry.get_meta(&"unix_time"));
			var time_diff := absi(
				time - int(prev.get_meta(&"unix_time"))
			);
			if time_diff >= biggestgap_time:
				biggestgap_time = time_diff;
				biggestgap_a = prev;
				biggestgap_b = entry;
		prev = entry;
	
	if !biggestgap_a:
		print("None found!!!");
	else:
		var hrs := snappedf(float(biggestgap_time) / 3600.0, 0.01);
		print("Between %s %s and %s %s - %s hour%s" % [
			biggestgap_a.date, biggestgap_a.username,
			biggestgap_b.date, biggestgap_b.username,
			hrs,
			"" if hrs == 1.0 else "s"
		]);
