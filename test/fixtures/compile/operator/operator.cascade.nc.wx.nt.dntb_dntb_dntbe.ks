func foobar(writer?, w, q, h) {
	writer
		?.code('*') if w
		?.code('?') if q
		?.code('#') if h
}