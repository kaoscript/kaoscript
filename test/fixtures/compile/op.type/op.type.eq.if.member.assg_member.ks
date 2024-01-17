func foobar(x: { value: Number | String }): Number {
	if x.value is Number {
		var y = x.value

		return y
	}

	return 0
}