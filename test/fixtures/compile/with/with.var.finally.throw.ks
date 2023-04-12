func open(): Number {
	return 0
}

func read(id: Number): String {
	return ''
}

func close(id: Number) {
}

func foobar() ~ Error {
	with var file = open() {
		throw Error.new()
	}
	finally {
		close(file)
	}
}