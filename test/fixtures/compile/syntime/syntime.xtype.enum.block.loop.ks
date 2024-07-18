enum Weekday {
    MONDAY      = (1, 'Monday')
    TUESDAY     = (2, 'Tuesday')
    WEDNESDAY   = (3, 'Wednesday')
    THURSDAY    = (4, 'Thursday')
    FRIDAY      = (5, 'Friday')
    SATURDAY    = (6, 'Saturday')
    SUNDAY      = (7, 'Sunday')

    const dayOfWeek: Number
    const printableName: String
}

syntime {
	for var { printableName } in Weekday.values {
		quote {
			echo(#(printableName))
		}
	}
}