require class Writer {
	code(value: String): Writer
}

func foobar(writer: Writer, w, q, h) {
	writer
		.code('|>')
		.code('#') if h
		.code(' ')
}