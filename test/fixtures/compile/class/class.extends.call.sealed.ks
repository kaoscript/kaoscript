impl Dictionary {
	static {
		merge(...args): Dictionary => {}
	}
}

class Foobar {
	private {
		@x: Number
	}
	constructor(options) {
		@x = options.x
	}
}

class Quxbaz extends Foobar {
	constructor(options? = null) {
		super(Dictionary.merge({
			x: 0
			y: 0
		}, options))
	}
}