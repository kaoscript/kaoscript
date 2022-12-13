require expect: func

var dyn foo = func(...args) {
	var dyn i = 42

	for i from 0 to~ args.length {
		expect(args[i]).to.equal(0)
	}
}

foo(0)