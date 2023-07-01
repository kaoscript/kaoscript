require expect: func

func fn(this) {
	return this.value
}

var obj = {
	value: 42
}

expect(fn*$(obj)).to.eql(42)