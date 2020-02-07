class Foobar {
	lateinit const PI: Number
	constructor() {
		@PI = 42

		const x = @PI + 3.14
	}
}

export Foobar