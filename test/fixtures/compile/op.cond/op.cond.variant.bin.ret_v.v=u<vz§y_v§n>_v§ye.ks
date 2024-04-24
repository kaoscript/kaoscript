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

func foobar(test: Boolean): Event<SchoolPerson> {
	var mut result: Event<SchoolPerson> = NO

	if test {
		result = loadJohn()
	}

	return result ?]] loadJohn()
}

func loadJohn(): Event<SchoolPerson>(Y) {
	return {
		ok: true
		value: {
			name: 'John'
		}
	}
}