class Foobar {
	lateinit const PI: Number
	constructor() {
		const x = @PI + 3.14

		@PI = 42
	}
}

export Foobar