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

func foobar(kind: Weekday(!SATURDAY, !SUNDAY)): DayData {
	return {
		kind
	}
}