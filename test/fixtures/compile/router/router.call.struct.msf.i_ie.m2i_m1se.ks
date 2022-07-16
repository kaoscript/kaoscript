#![rules(ignore-misfit)]

struct StructA {
	x: Number
	y: Number
}

func foobar(a: String, b: Number) {
	return StructA(y: b, x: a)
}