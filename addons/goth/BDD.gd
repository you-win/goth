class_name BDD
extends Reference

var goth

class Tuple2:
	var _v0
	var _v1

	func _init(v0, v1) -> void:
		_v0 = v0
		_v1 = v1

	func g0():
		return _v0
	
	func g1():
		return _v1
	
	func s0(value):
		_v0 = value

	func s1(value):
		_v1 = value

class Result:
	var _tuple: Tuple2

	func _init(v0, v1) -> void:
		_tuple = Tuple2.new(v0, v1)

	func unwrap():
		# Error
		if _tuple.g1():
			AppManager.log_message("Unwrapped an error", true)
			return null
		else:
			return _tuple.g0()

	func unwrap_err() -> String:
		return _tuple.g1()

	func is_ok() -> bool:
		return not _tuple.g1()

	func is_err() -> bool:
		return not is_ok()

	func set_value(value) -> void:
		_tuple.s0(value)

	func set_error(value) -> void:
		_tuple.s1(value)

class Tokenizer:
	enum { None = 0, ParseSpace, ParseSymbol, ParseQuotation, ParseBracket }

	const EXP_END: String = "__exp_end__"

	var _current_type: int = None
	var _is_escape_character: bool = false

	var _token_builder: PoolStringArray = PoolStringArray()

	func _build_token(result: Array) -> void:
		if _token_builder.size() != 0:
			result.append(_token_builder.join(""))
			_token_builder = PoolStringArray()
	
	func tokenize(value: String) -> Result:
		var result: Array = []
		var error

		var paren_counter: int = 0
		var square_bracket_counter: int = 0
		var curly_bracket_counter: int = 0
		
		# Checks for raw strings of size 1
		if value.length() <= 2:
			return Result.new(result, "Program too short")

		for i in value.length():
			var c: String = value[i]
			if c == '"':
				if _is_escape_character: # This is a double quote literal
					_token_builder.append(c)
					_is_escape_character = false
				elif _current_type == ParseQuotation: # Close the double quote
					_token_builder.append(c)
					_current_type = None
					_build_token(result)
				else: # Open the double quote
					_token_builder.append(c)
					_current_type = ParseQuotation
			elif _current_type == ParseQuotation:
				if c == "\\":
					_is_escape_character = true
				else:
					_token_builder.append(c)
			else:
				match c:
					"(":
						paren_counter += 1
						_build_token(result)
						_current_type = ParseBracket
						result.append(c)
					")":
						paren_counter -= 1
						_build_token(result)
						_current_type = None
						result.append(c)
					"[":
						square_bracket_counter += 1
						_build_token(result)
						_current_type = ParseBracket
						result.append(c)
					"]":
						square_bracket_counter -= 1
						_build_token(result)
						_current_type = None
						result.append(c)
					"{":
						curly_bracket_counter += 1
						_build_token(result)
						_current_type = ParseBracket
						result.append(c)
					"}":
						curly_bracket_counter -= 1
						_build_token(result)
						_current_type = None
						result.append(c)
					" ", "\t":
						_build_token(result)
						_current_type = ParseSpace
					"\r\n", "\n":
						_build_token(result)
						result.append(EXP_END)
						_build_token(result)
					_:
						_current_type = ParseSymbol
						_token_builder.append(c)

		if paren_counter != 0:
			result.clear()
			error = "Mismatched parens"

		if square_bracket_counter != 0:
			result.clear()
			error = "Mismatched square brackets"

		if curly_bracket_counter != 0:
			result.clear()
			error = "Mismatched curly brackets"

		return Result.new(result, error)

class Parser:
	enum { None = 0, Given, When, Then }
	var _current_type: int = None

	var _method_builder: PoolStringArray = PoolStringArray()

	var _param_builder: PoolStringArray = PoolStringArray()

	func _build_method(result: Array) -> void:
		if _method_builder.size() != 0:
			result.append(_method_builder.join("_"))
			_method_builder = PoolStringArray()

	func _build_param(result: Array) -> void:
		if _param_builder.size() != 0:
			result.append(_param_builder.join(""))
			_param_builder = PoolStringArray()

	func parse(tokens: Array) -> Result:
		var methods: Array = []
		var params: Array = []
		var error

		var is_param: bool = false
		
		if tokens.size() == 0:
			return Result.new(null, "Unexpected EOF")

		tokens.invert()
		var token: String = tokens.pop_back()

		while true:
			match token.to_lower():
				"given":
					if _current_type != None:
						return Result.new(null, "Given clause must be the first clause")
					_current_type = Given
				"when":
					if _current_type != Given:
						return Result.new(null, "When clause must come directly after Given")
					_current_type = When
				"then":
					if _current_type != When:
						return Result.new(null, "Then clause must come directly after When")
					_current_type = Then
				"(":
					is_param = true
				")":
					is_param = false
					_build_param(params)
				Tokenizer.EXP_END, "and":
					_build_method(methods)
				_:
					if not is_param:
						_method_builder.append(token)
					else:
						_param_builder.append(token)
			
			if tokens.empty():
				break
			token = tokens.pop_back()

		if not _method_builder.empty():
			_build_method(methods)

		if not _param_builder.empty():
			error = "Hanging parameter"

		return Result.new(Tuple2.new(methods, params), error)

###############################################################################
# Builtin functions                                                           #
###############################################################################

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func run(file_name: String) -> void:
	var tokenizer: Tokenizer = Tokenizer.new()
	var parser: Parser = Parser.new()

	var file: File = File.new()
	if file.open(file_name, File.READ) == OK:
		var content: String = file.get_as_text()
		file.close()

		var t_result: Result = tokenizer.tokenize(content)
		if t_result.is_err():
			goth.log_message("Unable to tokenize %s" % file_name)
		
		var tokens: Array = t_result.unwrap()
		
		var p_result: Result = parser.parse(tokens)
		if p_result.is_err():
			goth.log_message("Unable to parse %s" % file_name)

		var bdd_data: Tuple2 = p_result.unwrap()
		var method_list: Array = bdd_data.g0()
		var param_list: Array = bdd_data.g1()
		
		print(method_list)
		print(param_list)
