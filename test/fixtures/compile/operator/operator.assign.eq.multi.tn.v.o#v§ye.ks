type Range = {
	start: Number
	end: Number
}

type Event<T> = {
	variant ok: Boolean {
		false, N {
			start: Number?
			end: Number?
		}
		true, Y {
			value: T
			start: Number
			end: Number
		}
	}
}

var NO: Event(N) = { ok: false }

func foobar(value: Event(Y)) {
	var mut x: Range? = null
	var mut y: Event = NO

	x = y = value
}