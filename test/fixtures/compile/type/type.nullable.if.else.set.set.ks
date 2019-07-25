extern test

func foobar(x) {
}

func quzbaz(x?) {
	if test() {
		x = 24
	}
	else {
		x = 42
	}

	foobar(x)
}