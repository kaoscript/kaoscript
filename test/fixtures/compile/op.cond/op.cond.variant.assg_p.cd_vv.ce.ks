type Event = {
	variant ok: Boolean {
		false {
		}
		true {
			value: String
		}
	}
}

func foobar(x: Event) {
	if var t ?]= event() {
		echo(`\(t.value)`)
	}
}

func event(): Event {
	return {
		ok: false
	}
}