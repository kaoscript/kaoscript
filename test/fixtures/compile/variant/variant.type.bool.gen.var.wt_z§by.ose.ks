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

var event: Event(Y) = { ok: true, value: 'hello' }