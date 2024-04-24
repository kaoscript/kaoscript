func foobar(parameters, mut index) {
	if parameters[index] is Number {
		index = parameters[index]:!!(Number) + 1
	}
}