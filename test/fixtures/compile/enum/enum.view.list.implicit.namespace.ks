enum Weekday {
    MONDAY
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

namespace NS {
	func foobar(day: Weekday(MONDAY, TUESDAY)) {
	}

	foobar(.MONDAY)

	export *
}

NS.foobar(.MONDAY)