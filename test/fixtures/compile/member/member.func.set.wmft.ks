func foobar(key: String, value) {
	var result = () => ''

	#[rules(ignore-misfit)]
	result[key] = value

	return result
}