func foobar(): String? {
	return 'foobar'
}

func quxbaz(): String {
	if var name = foobar() {
		return name
	}
	else {
		return 'quxbaz'
	}
}