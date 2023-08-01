func foobar(writer?, w, q, h) {
	writer
		?.code('#') if h
		.code(' ').code('?') if q(writer)
}