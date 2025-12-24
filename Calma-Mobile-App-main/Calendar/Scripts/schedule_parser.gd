# Author: Rajwol Chapagain

class_name ScheduleParser

static func get_courses(schedule_text: String) -> Array[Course]:
	var parsed_courses: Array[Course] = []

	var course_line_follows = false
	for line in schedule_text.split('\n'):
		if course_line_follows and not line.strip_edges().is_empty():
			var course: Course = _get_course_from_line(line)
			if course != null:
				parsed_courses.append(course)
			
		if line.begins_with('Course'):
			course_line_follows = true
		elif line.strip_edges().is_empty():
			course_line_follows = false
	
	return parsed_courses
	
static func _get_course_from_line(line: String) -> Course:
	var items = line.split('\t')
	
	var days: String = items[7]
	# Some independent study classes don't have dates. We don't parse them
	if days.strip_edges().is_empty():
		return null
			
	var title: String = items[0]
	if title.ends_with('.'):
		title = title.get_slice('.', 0)
	var start_date: String = items[5]
	var end_date: String = items[6]
	var weekdays: Array[Time.Weekday] = []
	for day: String in items[7].split(' '):
		weekdays.append(_get_weekday_from_char(day))
			
	var start_time: String = _get_24_hr_time_format(items[8])
	var end_time: String = _get_24_hr_time_format(items[9])
	
	return Course.new(title, start_date, end_date, weekdays, start_time, end_time)

static func _get_weekday_from_char(c: String) -> Time.Weekday:
	if c == 'M':
		return Time.Weekday.WEEKDAY_MONDAY
	elif c == 'T':
		return Time.Weekday.WEEKDAY_TUESDAY
	elif c == 'W':
		return Time.Weekday.WEEKDAY_WEDNESDAY
	elif c == 'R':
		return Time.Weekday.WEEKDAY_THURSDAY
	elif c == 'F':
		return Time.Weekday.WEEKDAY_FRIDAY
	else:
		printerr('Error: Class day outside range Monday-Friday')
		return Time.WEEKDAY_SATURDAY

# Precondition: time is in the format HH:MM AM/PM
# Postcondition: Returns time in 24-hr format: HH:MM
static func _get_24_hr_time_format(time: String) -> String:
	time = time.strip_edges()
	var am_or_pm = time.substr(len(time) - 2, 2)
	var hour: int = int(time.substr(0, time.find(':')))
	var minute = time.substr(time.find(':') + 1, 2)
	
	hour %= 12
	
	if am_or_pm == 'PM':
		hour += 12
	
	var out_string = '%s:%s' % [hour, minute]
	if hour < 10:
		out_string = '0' + out_string
		
	return out_string
