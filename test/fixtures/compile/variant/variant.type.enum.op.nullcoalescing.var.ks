type Position = {
	line: Number
	column: Number
}

type Range = {
	start: Position
	end: Position
}

type Event = {
	variant ok: Boolean {
		false, N {
			expecteds: String[]?
		}
		true, Y {
			value
			start: Position
			end: Position
		}
	}
}

func foobar(mut first: Range?) {
	var event = getEvent()

	first ??= event
}

func getEvent(): Event(Y) {
	return {
		ok: true
		value: 0
		start: { line: 1, column: 1 }
		end: { line: 1, column: 1 }
	}
}