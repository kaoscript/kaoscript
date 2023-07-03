func foobar() {
}

func quxbaz() ~ Error {
	var dyn x

	if x !?= foobar() {
		throw Error.new()
	}

	return x.y
}