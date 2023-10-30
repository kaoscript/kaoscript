struct Event {
	ok: Boolean
	value?				= null
}

class Foobar {
	throw(expected: String): Never ~ Error {
		throw Error.new(`Expecting "\(expected)"`)
	}
	throw(...expecteds: String): Never ~ Error {
		throw Error.new(`Expecting "\(expecteds.join('", "'))"`)
	}
	foobar(event: Event): Event ~ Error {
		@throw(...?event.value)
	}
}