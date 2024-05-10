enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

type WeekdayData = {
	variant kind: Weekday {
		MONDAY, SATURDAY {
			message: String
		}
	}
}

func foobar(kind: Weekday(MONDAY, SATURDAY), message: String): WeekdayData {
	return {
		kind
		message
	}
}