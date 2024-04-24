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

type WeekendJob = {
	variant day: Weekend
	name: String
}

func getWeekendJob(day: Weekday, name: String): WeekendJob {
	return {
		day
		name
	}!!!
}
