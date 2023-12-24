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

type WeekendDay = Weekday(attribute ~~ .Weekend)

type WeekendJob = {
	name: String
	day: WeekendDay
}