func foobar(value?, type: String) {
	unless ?value {
		return
	}

	if !?value.type {
		echo(`\(value.type)`)
	}
	else {
		value.type = type
		echo(`\(value.type)`)
	}
}