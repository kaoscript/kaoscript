bitmask DayAttr {
	Nil
	Weekend
}

enum Weekday {
    MONDAY		= (DayAttr.Nil)
    TUESDAY		= (DayAttr.Nil)
    WEDNESDAY	= (DayAttr.Nil)
    THURSDAY	= (DayAttr.Nil)
    FRIDAY		= (DayAttr.Nil)
    SATURDAY	= (DayAttr.Weekend)
    SUNDAY		= (DayAttr.Weekend)

	const attribute: DayAttr
}

type Weekend = Weekday(attribute ~~ DayAttr.Weekend)

func isWeekend(day: Weekday) {
    return day is Weekend
}