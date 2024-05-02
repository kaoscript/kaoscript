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
	var mut event: Event = NO

	repeat {
		if test() {
			if ?]event {
				return
			}

			event = { ok: true, value: 0 }
		}
	}
}