type Event = {
	variant ok: Boolean {
		false {
			message: String
		}
		true {
			value: String
		}
	}
}

func foobar(x: Event) {
	if var t ?|= x {
	}
}