func foobar(x: String, ...values) {
}

class Foobar {
	foobar(x: String, values: Number[], more: Number) {
		foobar(x, ...values, more)
	}
}