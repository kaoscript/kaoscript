extern {
	func quxbaz
}

class Foobar {
	foobar(value?) {
		return value
			|>?	quxbaz
			|>	@quxbaz(_)
	}
	quxbaz(value?) {
	}
}