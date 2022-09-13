func foobar(): String {
	return ''
}

func quxbaz(x: String) {
}

with var x = foobar() {
	quxbaz(x)
}

quxbaz(x)