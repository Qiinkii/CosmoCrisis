extends Node

const DEFAULT_LOCALE := "uk"
const LOCALE_PATH := "res://localization/locales.json"

var current_language: String = DEFAULT_LOCALE
var _locales: Dictionary = {}

func _ready() -> void:
	_load_locales()
	set_language(current_language)

func _load_locales() -> void:
	if not FileAccess.file_exists(LOCALE_PATH):
		push_error("Missing localization file: %s" % LOCALE_PATH)
		return

	var file := FileAccess.open(LOCALE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open localization file: %s" % LOCALE_PATH)
		return

	var json := JSON.new()
	var parse_error := json.parse(file.get_as_text())
	if parse_error != OK:
		push_error("Failed to parse localization JSON: %s" % json.get_error_message())
		return

	var data = json.data
	if data is Dictionary:
		_locales = data
	else:
		push_error("Localization data must be a dictionary.")

func set_language(locale_code: String) -> String:
	if locale_code == "" or not _locales.has(locale_code):
		locale_code = DEFAULT_LOCALE
	current_language = locale_code
	return current_language

func translate_key(key: String, default_value: String = "") -> String:
	if _locales.is_empty():
		_load_locales()
	if _locales.has(current_language) and _locales[current_language].has(key):
		return String(_locales[current_language][key])
	if _locales.has(DEFAULT_LOCALE) and _locales[DEFAULT_LOCALE].has(key):
		return String(_locales[DEFAULT_LOCALE][key])
	if default_value != "":
		return default_value
	return key

func trf(key: String, args: Array = []) -> String:
	var text := translate_key(key)
	if args.is_empty():
		return text
	return text % args
