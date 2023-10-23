type Event<T> = {
	variant ok: Boolean {
		false {
			expecting: String?
		}
		true {
			value: T
		}
	}
}

var event: Event(true) = { ok: true, value: 'hello' }