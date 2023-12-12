func foobar(values: Number[]?) {
	return {
		values: [value * value for var value in values] if ?values
	}
}