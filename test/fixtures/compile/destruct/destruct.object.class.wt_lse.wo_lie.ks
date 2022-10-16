class Foobar {
	private {
		@positions: String[] = []
	}
	foobar(data: { positions: Number[] }) {
		{ @positions } = data
	}
}