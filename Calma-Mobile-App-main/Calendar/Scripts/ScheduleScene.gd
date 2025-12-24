# Author: Dominic Oregon
# Co-author: Rajwol Chapagain

extends Control

@export var COURSE_ROW_SCENE: PackedScene

@onready var class_list = %ClassList
@onready var date_label = %DateLabel

const ATTENDED_CLASSES_DIR: String = 'user://AttendedClasses'

func _ready():
	if not DirAccess.dir_exists_absolute(ATTENDED_CLASSES_DIR):
		DirAccess.make_dir_absolute(ATTENDED_CLASSES_DIR)
		
	var courses = []
	var save_dir = 'user://' + SettingsPanel.SAVE_DIRECTORY_NAME

	for item in ResourceLoader.list_directory(save_dir):
		var resource = ResourceLoader.load(save_dir + '/' + item)
		courses.append(resource)
	
	if courses.is_empty():
		%WarningLabel.visible = true
		return

	var today = Time.get_datetime_dict_from_system().weekday
	# Modify today as follows for testing:
	#var today = Time.WEEKDAY_TUESDAY
	
	var weekday_index_to_string = {
		0: "Sunday",
		1: "Monday",
		2: "Tuesday",
		3: "Wednesday",
		4: "Thursday",
		5: "Friday",
		6: "Saturday"
	}
	date_label.text = "Classes for " + weekday_index_to_string[today]

	for child in class_list.get_children():
		child.queue_free()

	var courses_today: Array[Course] = []
	
	for course: Course in courses:
		# Ignore courses that have yet to begin or have already ended
		if course.get_start_date_string_in_iso_format() > Time.get_date_string_from_system() or Time.get_date_string_from_system() > course.get_end_date_string_in_iso_format():
			continue
		
		if today in course.weekdays:
			courses_today.append(course)

	courses_today.sort_custom(func (course_a: Course, course_b: Course): return course_a.start_time < course_b.start_time)
	
	for course: Course in courses_today:
		var course_row: CourseRow = COURSE_ROW_SCENE.instantiate()
		# Sample path: user://AttendedClasses/COM 420 2025-12-07.save
		var save_path: String = "%s/%s %s.save" % [ATTENDED_CLASSES_DIR, course.title, Time.get_date_string_from_system()]
		var save_file_exists: bool = FileAccess.file_exists(save_path)
		course_row.initialize(course.title, save_file_exists)
		
		if not save_file_exists:
			course_row.checked.connect(_on_checkbox_pressed.bind(save_path))
			
		class_list.add_child(course_row)


	if courses_today.is_empty():
		%WarningLabel.text = "No Classes Today 🥳"
		%WarningLabel.visible = true

func _on_checkbox_pressed(save_path: String):
	var f = FileAccess.open(save_path, FileAccess.WRITE)
	f.store_var(true)
	f.close()
	Utils.add_coins(1)
