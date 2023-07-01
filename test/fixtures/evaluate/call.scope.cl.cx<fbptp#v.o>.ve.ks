require expect: func

func build(this, value) {
	expect(this.value).to.eql(value)

	return value
}

var obj = {
	value: 42
}
var fn = build^$(obj, ^)

expect(fn(42)).to.eql(42)