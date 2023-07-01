require expect: func

func use(build) {
	var fn = build(42)
	expect(fn()).to.eql(42)
}

use(func(value) {
	return () => value
})