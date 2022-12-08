struct Foobar {
	values: Object<String>
}

struct Quxbaz {
	values: Object<Number>
}

func foobar(item: Foobar | Quxbaz) {
	for var value of item.values {

	}
}