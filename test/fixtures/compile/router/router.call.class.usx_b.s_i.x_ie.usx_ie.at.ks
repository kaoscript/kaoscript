class Foobar {
	foobar(pattern: RegExp | String, position: Boolean) {
		@foobar(pattern, 0)
	}
	foobar(pattern: String, position: Number) {
	}
	foobar(pattern: RegExp, position: Number) {
	}
}