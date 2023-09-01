struct Event {
	ok: Boolean
	value
}

func foobar() {
	var dyn event

	if (event <- quxbaz()).ok {
	}
}

func quxbaz() {
}