enum Foobar {
	Foobar
}

func foobar() {
	return ''
}

match foobar() {
	is String {
	}
	Foobar.Foobar {
	}
}