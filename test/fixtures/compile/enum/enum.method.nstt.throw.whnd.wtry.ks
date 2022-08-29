enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY

    isWeekend(): Boolean ~ Error {
		throw new Error()
	}
}

func foobar(day: Weekday) {
    if (wk <- try day.isWeekend() ~ false) && wk {
    }
}

export Weekday