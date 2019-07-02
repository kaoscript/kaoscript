func foobar(): String? {
	return 'foobar'
}

func quxbaz(): String {
	if const name = foobar() {
		return name
	}
	else {
		return 'quxbaz'
	}
}