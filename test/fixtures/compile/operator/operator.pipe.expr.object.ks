extern {
	func quxbaz

	class Foobar
}

func foobar(value?) {
	return value
		|>?	quxbaz
		|>	{ value: _ }
}