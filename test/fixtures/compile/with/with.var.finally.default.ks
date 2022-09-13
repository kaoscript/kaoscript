func open(): Number {
	return 0
}

func read(id: Number): String {
	return ''
}

func close(id: Number) {
}

func foobar() {
	with var file = open() {
		var text = read(file)
	}
	finally {
		close(file)
	}
}