type Event<T> = {
	variant ok: Boolean {
		false, N {
		}
		true, Y {
			value: T
		}
	}
}

var NO: Event(N) = { ok: false }

func foobar(test) {
	var mut e: Event = NO

	if test() {
		e = getString()
	}
	else {
		e = getNumber()
	}

	if ?]e {
	}
}

func getString(): Event<String> {
	return { ok: true, value: 'Hello!' }
}

func getNumber(): Event<Number> {
	return { ok: true, value: 42 }
}