type Event = {
	variant ok: Boolean {
		false, N {
			expecting: String?
		}
		true, Y {
			value: String
		}
	}
}

class Foobar {
	getNoValue(event: Event(N)) {
		return event.expecting
	}
	getYesValue(event: Event(Y)) {
		return event.value
	}
}