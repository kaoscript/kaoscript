func foobar(values: { names: String[] }?): String[] {
	if var { names } ?= values {
		return names
	}

	return []
}