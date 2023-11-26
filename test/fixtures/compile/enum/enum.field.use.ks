enum Weekday {
    MONDAY      = (1, 'Monday') & 1
    TUESDAY     = (2, 'Tuesday')
    WEDNESDAY   = (3, 'Wednesday')
    THURSDAY    = (4, 'Thursday')
    FRIDAY      = (5, 'Friday')
    SATURDAY    = (6, 'Saturday')
    SUNDAY      = (7, 'Sunday')

    const dayOfWeek: Number
    const printableName: String
}

func print(day: Weekday) {
	echo(`\(day.printableName)`)

	if day.dayOfWeek == 1 {
		echo(`It's Monday :(`)
	}
}