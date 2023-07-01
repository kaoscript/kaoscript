require expect: func

func use(build) {
	var fns = []

	build((fn) => {
		fns.push(fn)
	})
	
	var obj = { pi: 3.14 }

	for var fn in fns {
		fn*$(obj)
	}
}

func assert(this, value) {
	expect(value).to.eql(42)
	expect(this.pi).to.eql(3.14)
}

use(func(add) {
	add(assert^^(42))
})