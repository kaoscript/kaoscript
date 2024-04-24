func foobar(x) {
	var mut y = 0
	var mut z = null

	if (y += 1, true) && (y += 1, z ?= x()) {
	}
}