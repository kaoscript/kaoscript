func foobar(values: Dictionary<String>, key: String) {
	lateinit const value: String
	
	if false || (value !?= values[key]) {
		value = ''
	}
}