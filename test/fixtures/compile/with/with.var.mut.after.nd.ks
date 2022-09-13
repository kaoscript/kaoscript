func foobar(): String {
	return ''
}

func quxbaz(x: String) {
}

with var mut x = foobar() {
	quxbaz(x)
}

quxbaz(x)