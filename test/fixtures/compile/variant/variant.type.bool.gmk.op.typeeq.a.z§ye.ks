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

func foobar(event) {
	if event is Event(Y) {
	}
}