require expect: func

func build() {
	return func(this) {
		return this.value
	}
}

var fn = build()
var obj = {
	value: 42
}

expect(fn*$(obj)).to.eql(42)