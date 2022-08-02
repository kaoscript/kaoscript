func foobar(...args) {
	var dyn x = args.pop()

	if x != 'a' {
		x = null
	}

	quxbaz(x)
}

func quxbaz(x: String = '') {
}