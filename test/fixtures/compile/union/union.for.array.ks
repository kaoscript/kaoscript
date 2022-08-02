struct Foobar {
	values: Array<String>
}

struct Quxbaz {
	values: Array<Number>
}

func foobar(item: Foobar | Quxbaz) {
	for var value in item.values {

	}
}