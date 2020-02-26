enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

impl Weekday {
	isWeekend(): Boolean => this == SATURDAY | SUNDAY
}

func foobar(day: Weekday) {
    if day.isWeekend() {
    }
}

export Weekday