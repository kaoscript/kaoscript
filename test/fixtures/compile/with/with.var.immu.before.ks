func foobar(): String {
	return ''
}

func quxbaz(x: String) {
}

var x = 0

with var x = foobar() {
	quxbaz(x)
}