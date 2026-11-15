extends Node

const DEFAULT_LOCALE := "uk"
const LOCALE_PATH := "res://localization/locales.json"

var current_language: String = DEFAULT_LOCALE
var _locales: Dictionary = {}

func _ready() -> void:
	_load_locales()

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

	if json.data is Dictionary:
		_locales = json.data
	else:
		push_error("Localization data must be a dictionary.")

func set_language(locale_code: String) -> String:
	if not _locales.has(locale_code):
		locale_code = DEFAULT_LOCALE
	current_language = locale_code
	return current_language

func translate_key(key: String, default_value: String = "") -> String:
	if _locales.is_empty():
		_load_locales()
	var locale: Dictionary = _locales.get(current_language, {})
	if locale.has(key):
		return String(locale[key])
	var fallback: Dictionary = _locales.get(DEFAULT_LOCALE, {})
	if fallback.has(key):
		return String(fallback[key])
	return default_value if default_value != "" else key

func trf(key: String, args: Array = []) -> String:
	var text := translate_key(key)
	return text if args.is_empty() else text % args
