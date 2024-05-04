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

func foobar(): DayData(!SATURDAY, !SUNDAY) {
	return {
		kind: .SUNDAY
		message: ''
	}
}