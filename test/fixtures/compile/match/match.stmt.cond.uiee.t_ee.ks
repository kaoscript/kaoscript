enum Foobar {
	Foobar
}

func foobar(): String | Foobar {
	return ''
}

match foobar() {
	is String {
	}
	Foobar.Foobar {
	}
}