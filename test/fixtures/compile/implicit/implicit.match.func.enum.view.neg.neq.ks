enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

func foobar(day: Weekday(!MONDAY, !TUESDAY, !FRIDAY)) {
}

func get() => 0

func quxbaz() {
	match get() {
		0 {
			foobar(.FRIDAY)
		}
	}
}