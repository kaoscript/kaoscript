struct Data {
	x: Boolean
}

class Foobar {
	private {
		@x: Boolean
	}
	constructor(data: Data) {
		{ @x } = data
	}
}