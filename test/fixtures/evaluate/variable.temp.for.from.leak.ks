require expect: func

func foo(...args) {
	let i = 42
	
	for i from 0 til args.length {
		expect(args[i]).to.equal(0)
	}
}

foo(0)