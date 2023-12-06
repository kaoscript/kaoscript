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

func foobar(load) {
	var late result

	if load {
		result = loadJohn()
	}
	else {
		result = NO
	}

	if result.ok {
		quxbaz(result)
	}
}

func quxbaz(person: Event<SchoolPerson>(Y)) {
}

func loadJohn(): Event<SchoolPerson> {
	return {
		ok: true
		value: {
			name: 'John'
		}
	}
}