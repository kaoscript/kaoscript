bitmask DayAttr {
	Default
	Weekend
}

enum Weekday {
    MONDAY		= (.Default)
    TUESDAY		= (.Default)
    WEDNESDAY	= (.Default)
    THURSDAY	= (.Default)
    FRIDAY		= (.Default)
    SATURDAY	= (.Weekend)
    SUNDAY		= (.Weekend)

	const attribute: DayAttr
}

type Weekend = Weekday(attribute ~~ .Weekend)

func foobar(day: Weekend) {
	echo(day.value)
}