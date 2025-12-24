# Author: Rajwol Chapagain

class_name SettingsPanel extends Control

const SAVE_DIRECTORY_NAME: String = 'SavedCourses'
const SAVE_PATH:String = "res://Global/TempSaves/Utils.tres"

signal schedule_imported

func _on_settings_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%ImportPanel.visible = true
	else:
		%ImportPanel.visible = false

func _on_import_button_pressed() -> void:
	save_courses_to_disk(ScheduleParser.get_courses(%ScheduleEntryTextField.text))
	%ScheduleEntryTextField.clear()
	%SettingsButton.button_pressed = false
	_on_settings_button_toggled(%SettingsButton.button_pressed)
	schedule_imported.emit()
	
func save_courses_to_disk(courses: Array[Course]) -> void:
	var save_directory = 'user://%s' % SAVE_DIRECTORY_NAME
	if not DirAccess.dir_exists_absolute(save_directory):
		DirAccess.make_dir_absolute(save_directory)

	for course in courses:
		ResourceSaver.save(course, save_directory + '/' + course.title + '.tres')
