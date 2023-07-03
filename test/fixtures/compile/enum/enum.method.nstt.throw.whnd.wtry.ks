enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY

    isWeekend(): Boolean ~ Error {
		throw Error.new()
	}
}

func foobar(day: Weekday) {
	var dyn wk

    if (wk <- try day.isWeekend() ~ false) && wk {
    }
}

export Weekday