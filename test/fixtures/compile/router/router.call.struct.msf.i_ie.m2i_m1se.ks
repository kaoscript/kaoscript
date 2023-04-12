#![rules(ignore-misfit)]

struct StructA {
	x: Number
	y: Number
}

func foobar(a: String, b: Number) {
	return StructA.new(y: b, x: a)
}