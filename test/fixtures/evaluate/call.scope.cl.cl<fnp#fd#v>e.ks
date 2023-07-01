require expect: func

func build(obj) {
	return () => {
		return obj.value
	}
}

var obj = {
	value: 42
}
var fn = build(obj)

expect(fn()).to.eql(42)