type Event<T> = {
	variant ok: Boolean {
		false, N {
			expecting: String?
		}
		true, Y {
			value: T
		}
	}
}

var event: Event<String>(Y) = { ok: true, value: 'hello' }