impl Object {
	static {
		merge(...args?): Object => {}
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
		super(Object.merge({
			x: 0
			y: 0
		}, options))
	}
}