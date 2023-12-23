bitmask DayAttr {
	Default
	DoubleRate
	Weekend
}

enum Weekday {
    MONDAY		= (.Default)
    TUESDAY		= (.Default)
    WEDNESDAY	= (.Default)
    THURSDAY	= (.Default)
    FRIDAY		= (.Default)
    SATURDAY	= (.Weekend)
    SUNDAY		= (.Weekend + .DoubleRate)

	const attribute: DayAttr
}

type Weekend = Weekday(attribute ~~ .Weekend)

func isWeekend(day: Weekday) {
    return day is Weekend
}

export *