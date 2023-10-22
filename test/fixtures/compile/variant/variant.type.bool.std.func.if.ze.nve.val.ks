type Event = {
	variant ok: Boolean {
		false {
			expecting: String
		}
		true {
			value: String
		}
	}
}

func greeting(event: Event) {
	if !event.ok {
		echo(`\(event.value)`)
	}
	else {
		echo(`\(event.expecting)`)
	}
}