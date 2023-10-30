func foobar(value) {
	if value.coord is String {
		var parts = /^(\d+);(\d+)$/.exec(value.coord)

		value.coord = {
			x: parts[1]
			y: parts[2]
		}
	}
}