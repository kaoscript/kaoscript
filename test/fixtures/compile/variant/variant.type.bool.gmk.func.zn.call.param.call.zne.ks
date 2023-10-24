type Event<T> = {
	variant ok: Boolean {
		false, N {
			expecting: String?
		}
		true, Y {
			value: T
			line: Number?
			column: Number?
		}
	}
}

func yes(): Event<Null> => { ok: true }

func foobar(event: Event?) {
}

foobar(yes())