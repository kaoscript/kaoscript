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

func getNoValue(event: Event(N)) {
	return event.expecting
}

func getYesValue(event: Event(Y)) {
	return event.value
}