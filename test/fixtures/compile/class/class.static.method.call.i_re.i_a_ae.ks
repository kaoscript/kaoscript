class ClassA {
	static foobar(x: Number, ...values) {
	}
}

func foobar(x: Number, y, z) {
	ClassA.foobar(x, y, z)
}