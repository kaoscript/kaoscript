require expect: func

func build(this, value) {
	expect(this.value).to.eql(value)

	return value
}

var fn = build^^(42)
var obj = {
	value: 42
}

expect(fn*$(obj)).to.eql(42)