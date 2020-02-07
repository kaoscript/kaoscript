class Foobar {
	private const @x = 42
	x(x: Number): Foobar {
		@x = x

		return this
	}
}