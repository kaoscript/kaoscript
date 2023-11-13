type Named = {
	name: String
}

type Event<T> = {
	value: T
}

func foobar<T is Named>(value: T, event: Event): T {
	return value
}

func quxbaz(event: Event<Named>) {
	foobar(event.value, event)
}