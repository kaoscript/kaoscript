func foobar(x: { value: Number | String }): Number {
	if x.value is Number {
		var y = x

		return y.value
	}

	return 0
}