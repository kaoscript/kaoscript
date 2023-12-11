enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

type Weekend = Weekday(SATURDAY, SUNDAY)

func foobar(day: Weekend) {
}

func quxbaz(day: Weekday) {
	if day == .SATURDAY | .SUNDAY {
		foobar(day)
	}
}