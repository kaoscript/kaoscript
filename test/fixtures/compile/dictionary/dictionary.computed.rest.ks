func foobar(names: Dictionary<Array<String>>, name: String, value: String) {
	var result = {
		...names
		[name]: value
	}
}