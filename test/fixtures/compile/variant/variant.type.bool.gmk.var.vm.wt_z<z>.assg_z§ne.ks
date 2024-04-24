type Event<T> = {
	variant ok: Boolean {
		false, N {
		}
		true, Y {
			value: T
		}
	}
}

type SchoolPerson = {
    name: string
}

var NO: Event(N) = { ok: false }
var mut event: Event<SchoolPerson> = NO