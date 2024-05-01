type Foobar = String[]

func foobar(values: Foobar{}, name: String): String[] {
	if var names ?= values[name] {
		return names.reverse()
	}

	return []
}