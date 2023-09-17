extern test

func foobar(x) {
}

func quzbaz(mut x?) {
	if test() {
		x = 24
	}
	else {
		x = 42
	}

	foobar(x)
}