func foobar() {
	if var x ?= quxbaz(); x is not Number || x == 0 {
	}
}

func quxbaz() {
	return 0
}