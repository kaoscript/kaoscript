enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

type WorkingDay = Weekday(!SUNDAY)

type WorkingDayData = {
	variant kind: WorkingDay {
		SATURDAY {
			message: String
		}
	}
}

func foobar(kind: WorkingDay(!SATURDAY)): WorkingDayData {
	return {
		kind
	}
}