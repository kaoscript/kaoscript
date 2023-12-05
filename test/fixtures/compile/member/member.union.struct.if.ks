struct StructAB {
    a: Number
    b: Number
	f: Boolean
}

struct StructABC extends StructAB {
	c: Number
}

struct StructABD extends StructAB {
	d: Number
}

type StructCD = StructABC | StructABD

func foobar(data: StructCD) {
	if data.f {
		var x = data.a + data.b
	}
}