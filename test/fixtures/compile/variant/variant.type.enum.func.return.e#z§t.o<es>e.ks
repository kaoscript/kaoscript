enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

type DayData = {
	variant kind: Weekday {
		SATURDAY, SUNDAY {
			message: String
		}
	}
}

func foobar(kind: Weekday): DayData(SATURDAY) {
	return {
		kind: .SATURDAY
		message: ''
	}
}