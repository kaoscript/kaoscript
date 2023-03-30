struct Data {
	positions: Number[]
}

class Foobar {
	private {
		@positions: Number[] = []
	}
	foobar(data: Data) {
		{ @positions } = data
	}
}