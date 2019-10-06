#![target(ecma-v5)]

class Foobar {
	private {
		@value
	}
	data(values) {
		values.push({
			value: @value.name()
		})
	}
}