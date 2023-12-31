func foobar(data) {
	var mut x = 0

	if data is [Number, Number] {
		x += data[1] - data[0]
	}
}