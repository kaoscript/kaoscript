require class Writer {
	code(value: String): Writer
}

func foobar(writer: Writer, w, q, h) {
	writer
		.code('*') if w
		.code('?') if q
		.code('#') if h
}