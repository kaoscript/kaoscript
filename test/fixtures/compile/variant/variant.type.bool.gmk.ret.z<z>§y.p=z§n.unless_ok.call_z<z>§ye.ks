type Event<T> = {
	variant ok: Boolean {
		false, N {
		}
		true, Y {
			value: T
		}
	}
}

type SchoolPerson = {
    name: string
}

var NO: Event(N) = { ok: false }

func foobar(mut result: Event): Event<SchoolPerson>(Y) {
	unless result.ok {
		result = loadJohn()
	}

	return result
}

func loadJohn(): Event<SchoolPerson>(Y) {
	return {
		ok: true
		value: {
			name: 'John'
		}
	}
}