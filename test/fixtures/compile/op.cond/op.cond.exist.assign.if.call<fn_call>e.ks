func foobar(fn, test) {
	var dyn result

	if result ?= fn(value => test(value)) {
	}
}