enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY

	isWeekend(sat: Boolean = true): Boolean => (sat && this == SATURDAY) || this == SUNDAY
}

impl Weekday {
	override isWeekend(sat) => (sat && this == FRIDAY | SATURDAY) || this == SUNDAY
}

func foobar(day: Weekday) {
    if day.isWeekend() {
    }
}

export Weekday