extends Node

var times: Dictionary[String, int] = {};
var weekdays: Dictionary[String, int] = {};
var hours: Dictionary[String, int] = {};

var list := LogEntry.list;

# agggh sunday at 0
const days_of_week = [
	"Sunday", "Monday", "Tuesday", "Wednesday",
	"Thursday", "Friday", "Saturday",
];
const days_of_week_actual = [
	"Monday", "Tuesday", "Wednesday", "Thursday",
	"Friday", "Saturday", "Sunday",
];

func _ready() -> void:
	for entry in list:
		var datetime := entry.date;
		if datetime.length() < "0000-00-00".length():
			datetime += " 0:00";
		# add seconds since those are never recorded
		datetime = datetime + ":00";
		var date_dict := Time.get_datetime_dict_from_datetime_string(
			datetime.replace("?", "1"), true
		);
		var date := "%04d-%02d-%02d" % [
			date_dict["year"], date_dict["month"], date_dict["day"]
		];
		if date == "20211-11-11":
			date = "2021-??-??";
		times[date] = times.get(date, 0) + 1;
		var wd := str(days_of_week[int(date_dict["weekday"])]);
		weekdays[wd] = weekdays.get(wd, 0) + 1;
		var hr := str(date_dict["hour"]);
		hours[hr] = hours.get(hr, 0) + 1;
	
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
