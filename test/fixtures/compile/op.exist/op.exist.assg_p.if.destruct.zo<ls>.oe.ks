type Foobar = {
	names: String[]
}

func foobar(values: Foobar?): String[] {
	if var { names } ?= values {
		return names
	}

	return []
}