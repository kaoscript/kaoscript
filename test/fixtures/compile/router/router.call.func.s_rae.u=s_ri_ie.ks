func foobar(x: String, ...values) {
}

class Foobar {
	foobar(a: String, values: Number[], more: Number) {
		foobar(a, ...values, more)
	}
}