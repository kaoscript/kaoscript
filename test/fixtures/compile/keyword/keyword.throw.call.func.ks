struct Event {
	ok: Boolean
	value?				= null
}

func throw(expected: String): Never ~ Error {
	throw Error.new(`Expecting "\(expected)"`)
}
func throw(...expecteds: String): Never ~ Error {
	throw Error.new(`Expecting "\(expecteds.join('", "'))"`)
}
func foobar(event: Event): Event ~ Error {
	if event.value is Array {
		throw(...event.value)
	}
	else if ?event.value {
		throw(event.value)
	}
	else {
		return event
	}
}