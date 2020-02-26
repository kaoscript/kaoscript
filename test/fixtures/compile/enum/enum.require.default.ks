require enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY

    isWeekend(): Boolean

	static fromString(value: String): Weekday?
}

func foobar(day: Weekday) {
    if day.isWeekend() {
    }
}

foobar(Weekday::WEDNESDAY)

export Weekday