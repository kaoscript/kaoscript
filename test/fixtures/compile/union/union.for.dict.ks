struct Foobar {
	values: Dictionary<String>
}

struct Quxbaz {
	values: Dictionary<Number>
}

func foobar(item: Foobar | Quxbaz) {
	for var value of item.values {

	}
}