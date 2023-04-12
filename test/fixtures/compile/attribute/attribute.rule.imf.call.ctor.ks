#![rules(ignore-misfit)]

class Foobar {
	private {
		_x
	}
	constructor(@x)
}

var f = Foobar.new(null)