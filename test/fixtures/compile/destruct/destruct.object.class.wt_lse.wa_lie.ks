type Data = {
	positions: Number[]
}

class Foobar {
	private {
		@positions: String[] = []
	}
	foobar(data: Data) {
		{ @positions } = data
	}
}