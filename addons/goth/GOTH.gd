tool
class_name GOTH
extends Reference

"""
GOTH Test Harness
uwu
"""

signal message_logged(message)

const TEST_PREFIX: String = "test"
const BASE_TEST_DIRECTORY: String = "res://tests/"

var test_paths: Array = [] # String

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _init() -> void:
	scan()

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func log_message(message: String) -> void:
	if Engine.editor_hint:
		emit_signal("message_logged", message)
	else:
		print(message)

func scan() -> void:
	var dir: Directory = Directory.new()
	var current_directory: String = BASE_TEST_DIRECTORY
	var directories: Array = [] # String
	
	# Loop through all found directories
	while dir.open(current_directory) == OK:
		dir.list_dir_begin(true, true)
		
		var file_name: String = dir.get_next()
		# Loop through current directory
		while file_name != "":
			var absolute_path: String = "%s/%s" % [dir.get_current_dir(), file_name]
			if dir.current_is_dir():
				directories.append(absolute_path)
			if file_name.left(4).to_lower() == TEST_PREFIX:
				test_paths.append(absolute_path)
			
			file_name = dir.get_next()
		
		if not directories.empty():
			current_directory = directories.pop_back()
		else:
			break

func run_unit_tests(test_name: String = "") -> void:
	for test in test_paths:
		if not test_name.empty():
			if test.get_file() == test_name:
				var specific_test = load(test).new()
				specific_test.goth = self
				if not specific_test.has_method("run_tests"):
					push_error("Invalid test file loaded")
					return
				log_message(test)
				specific_test.run_tests()
				break
			else:
				continue
		
		var test_file = load(test).new()
		test_file.goth = self
		if not test_file.has_method("run_tests"):
			push_error("Invalid test file loaded")
			return
		log_message(test)
		test_file.run_tests()

func run_bdd_tests(test_name: String = "") -> void:
	log_message("Not yet implemented")
