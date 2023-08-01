func foobar(writer?, w, q, h) {
	writer
		?.code(' ')
		?.code('*') if w
		?.code('|>')
		?.code('?') if q
		?.code('#') if h
		?.code(' ')
}