type Foobar = {
	names: String[]
	type: String
}

func foobar(values: Foobar?): String[] {
	if var { names } ?= values {
		return names
	}

	return []
}