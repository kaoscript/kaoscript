func foobar(values) {
	for var i from values.low() to values.high() step values.step() {
		return i
	}
	else {
		return 0
	}
}