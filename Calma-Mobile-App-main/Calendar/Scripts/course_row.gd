# Author: Rajwol Chapagain

class_name CourseRow extends Control

@export var course_title: String

signal checked

func _ready() -> void:
	%TitleLabel.text = course_title

func initialize(course_title_: String, attended: bool = false) -> void:
	course_title = course_title_
	if attended:
		%CheckBox.button_pressed = true
		_on_check_box_toggled(%CheckBox.button_pressed)
		
func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%CheckBox.disabled = true
		checked.emit()
