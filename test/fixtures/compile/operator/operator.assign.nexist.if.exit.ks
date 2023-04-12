func foobar() {
}

func quxbaz() ~ Error {
	if x !?= foobar() {
		throw Error.new()
	}

	return x.y
}