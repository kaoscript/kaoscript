extern {
	func quxbaz
}

class Foobar {
	foobar(value?) {
		return value
			|>?	quxbaz
			|>	@quxbaz
	}
	quxbaz(value?) {
	}
}