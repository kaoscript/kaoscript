class Foobar {
	private {
		@x: Boolean
	}
	constructor(data: { x: Boolean, y: Boolean }) {
		{ @x } = data
	}
}