extern test

func foobar(x) {
}

func quzbaz(x?) {
	if test() {
		return 24
	}
	else {
		x = 42
	}

	foobar(x)
}