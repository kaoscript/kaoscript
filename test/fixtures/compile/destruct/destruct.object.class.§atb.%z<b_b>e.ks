type Data = {
	x: Boolean
	y: Boolean
}

class Foobar {
	private {
		@x: Boolean
	}
	constructor(data: Data) {
		{ @x } = data
	}
}