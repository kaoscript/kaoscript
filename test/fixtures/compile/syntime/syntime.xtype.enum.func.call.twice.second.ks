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

syntime func myMacro(day: Weekday) {
	quote {
		echo('the day is: #(day.printableName)')
	}
}

syntime func myMacro2(day: Weekday) {
	quote {
		echo('the second day is: #(day.printableName)')
	}
}

myMacro2(Weekday.SUNDAY)

myMacro(Weekday.MONDAY)