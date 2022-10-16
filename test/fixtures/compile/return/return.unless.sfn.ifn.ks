func foobar(values, fn) {
	var keys = Dictionary.keys(values).sort((a, b) => {
		var x = fn(0)

		return 0 unless x > 0
	})
}