class Foobar {
	public {
		value: String
	}
	constructor(@value)
	constructor(value: Boolean | Number) {
		@value = `\(value)`
	}
}

class Quxbaz extends Foobar {
	constructor(value: Boolean | Number | String) {
		super(value)
	}
}