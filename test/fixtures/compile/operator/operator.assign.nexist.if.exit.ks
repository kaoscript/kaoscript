func foobar() {
}

func quxbaz() ~ Error {
	if x !?= foobar() {
		throw new Error()
	}

	return x.y
}