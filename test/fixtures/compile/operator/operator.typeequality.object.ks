func foobar(data) {
	var mut x = 0

	if data is { from: Number, to: Number } {
		x += data.to - data.from
	}
}