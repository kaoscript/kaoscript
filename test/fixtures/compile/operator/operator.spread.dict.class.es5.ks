#![target(ecma-v5)]

class Foobar {
	private {
		@values: Dictionary = {}
	}
	foobar() {
		const values = {...@values}
	}
}