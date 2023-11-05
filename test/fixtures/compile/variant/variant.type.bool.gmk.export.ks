type Event<T> = {
	variant ok: Boolean {
		false, N {
			expecting: String
		}
		true, Y {
			value: T
		}
	}
}


export Event