func foobar() {
	var values = []

	var mut i = 1

	repeat {
		values.push(i)

		if i > 10 {
			break
		}
		else {
			i += 1
		}
	}

	echo(`\(values[0])`)
}