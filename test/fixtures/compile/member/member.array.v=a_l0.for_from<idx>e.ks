func foobar() {
	var values = []

	for var i from 1 to 10 {
		if i % 2 == 1 {
			values.push(i)
		}
		else {
			echo(`\(values[0])`)
		}
	}
}