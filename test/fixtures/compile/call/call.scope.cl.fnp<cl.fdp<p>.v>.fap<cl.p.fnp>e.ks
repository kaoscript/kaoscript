require expect: func

func use(build) {
	var fns = []

	build((fn) => {
		fns.push(fn)
	})

	for var fn in fns {
		fn(42)
	}
}

use(func(add) {
	func assert(value) {
		expect(value).to.eql(42)
	}

	add(assert)
})