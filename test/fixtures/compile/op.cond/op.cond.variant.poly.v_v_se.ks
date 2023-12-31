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

func foobar(a: Event, b: Event, c: String) {
	var x = a ?|| b ?|| c
}