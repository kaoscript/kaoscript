func foobar(names: Object<Array<String>>, name: String, value: String) {
	var result = {
		...names
		[name]: value
	}
}