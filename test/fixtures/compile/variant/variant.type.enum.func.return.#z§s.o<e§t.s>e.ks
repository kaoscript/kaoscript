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

func foobar(): DayData(SUNDAY) {
	return {
		kind: .SATURDAY
		message: ''
	}
}