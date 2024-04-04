type Event<T> = {
	variant ok: Boolean {
		false, N {
			errors: String[]?
		}
		true, Y {
			value: T
		}
	}
}

class Foobar {
	foobar<T is Event>(value: T) {
	}
}