bitmask DayAttr {
	Nil
	Weekend
}

enum Weekday {
    MONDAY		= (.Nil)
    TUESDAY		= (.Nil)
    WEDNESDAY	= (.Nil)
    THURSDAY	= (.Nil)
    FRIDAY		= (.Nil)
    SATURDAY	= (.Weekend)
    SUNDAY		= (.Weekend)

	const attribute: DayAttr
}

type Weekend = Weekday(attribute ~~ .Weekend)

func isWeekend(day: Weekday) {
    return day is Weekend
}