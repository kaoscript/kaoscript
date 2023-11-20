type Position = {
	line: Number
	column: Number
}

type Event = {
	variant ok: Boolean {
		false, N {
		}
		true, Y {
			value: Number
			line: Number
			column: Number
		}
	}
}

func foobar({ line }: Position) {
}

func quxbaz(value: Event) {
	foobar(value)
}