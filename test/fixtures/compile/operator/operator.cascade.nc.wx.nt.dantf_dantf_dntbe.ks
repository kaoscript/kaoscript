func foobar(writer?, w, q, h) {
	writer
		.code('')?.code('*') if w(writer)
		.code('')?.code('?') if q(writer)
		?.code('#') if h
}