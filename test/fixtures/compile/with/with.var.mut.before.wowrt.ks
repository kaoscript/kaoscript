func foobar(): String {
	return ''
}

func quxbaz(x: String) {
}

var mut x = 0

with #[overwrite] var mut x = foobar() {
	quxbaz(x)
}