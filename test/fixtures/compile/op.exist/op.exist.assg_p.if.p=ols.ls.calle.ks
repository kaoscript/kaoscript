func foobar(values: String[]{}, name: String): String[] {
	if var names ?= values[name] {
		return names.reverse()
	}

	return []
}