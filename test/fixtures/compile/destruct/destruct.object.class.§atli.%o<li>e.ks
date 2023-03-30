class Foobar {
	private {
		@positions: Number[] = []
	}
	foobar(data: { positions: Number[] }) {
		{ @positions } = data
	}
}