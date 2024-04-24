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

func foobar(x: Event): Event(true) {
	return x ?]] { ok: true, value: 'hello' }
}