func foobar(value?) {
	return value |>? quxbaz |>? corge
}

func quxbaz(value: Any): Any {
	return value
}

func corge(value: Any): Any {
	return value
}