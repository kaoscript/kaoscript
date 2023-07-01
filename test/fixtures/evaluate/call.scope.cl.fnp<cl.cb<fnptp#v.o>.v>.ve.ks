require expect: func

func build(this, value: Number) {
	return this.pi * value
}

var obj = { pi: 3.14 }
var fn = build^$(obj, ^)

func test(value) {
	expect(fn(value)).to.eql(3.14 * value)
}

test(1)