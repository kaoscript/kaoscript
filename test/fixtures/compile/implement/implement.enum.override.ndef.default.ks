enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY

	isWeekend(): Boolean => this == SATURDAY | SUNDAY
}

impl Weekday {
	override isWeekend() => this == SATURDAY | SUNDAY | FRIDAY
}

func foobar(day: Weekday) {
    if day.isWeekend() {
    }
}

export Weekday