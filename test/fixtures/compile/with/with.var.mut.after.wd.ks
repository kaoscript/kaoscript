func foobar(): String {
	return ''
}

func quxbaz(x: String) {
}

with var mut x = foobar() {
	quxbaz(x)
}

var mut x = 0