func foobar(mut x, mut y) {
	var result = quxbaz()

	if !?result {
	}
	else {
		{ x, y } = result
	}
}

func quxbaz(): { x, y }? {
	return null
}