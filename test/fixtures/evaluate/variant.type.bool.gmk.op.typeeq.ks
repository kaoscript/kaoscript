require expect: func

type Event<T> = {
	variant ok: Boolean {
		false, N {
			expecting: String
		}
		true, Y {
			value: T
		}
	}
}

func tests(event) {
	expect(event is Event).to.equal(true)
	expect(event is Event<String>).to.equal(true)
	expect(event is Event(Y)).to.equal(true)
	expect(event is Event<String>(Y)).to.equal(true)
}

var event = {
	ok: true
	value: 'hello'
}

tests(event)