class Foobar {
	foobar(x, y, z) => 1
	quxbaz() {
		var fn = @foobar^^(0, 1)

		fn(2)
	}
}