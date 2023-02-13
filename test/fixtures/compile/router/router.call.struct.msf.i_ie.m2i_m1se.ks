#![rules(ignore-misfit)]

struct StructA {
	x: Number
	y: Number
}

func foobar(a: String, b: Number) {
	return new StructA(y: b, x: a)
}