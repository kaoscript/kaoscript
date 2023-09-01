require {
	func quxbaz()
}

func foobar(test) {
	var mut x = null

	x = if test {
		set quxbaz()
			..foobar()
	}
	else {
		set 0
	}
}