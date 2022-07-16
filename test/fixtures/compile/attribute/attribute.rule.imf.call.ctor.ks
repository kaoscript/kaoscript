#![rules(ignore-misfit)]

class Foobar {
	private {
		_x
	}
	constructor(@x)
}

const f = new Foobar(null)