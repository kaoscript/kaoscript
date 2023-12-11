bitmask WeekdayAttribute {
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

	const attribute: WeekdayAttribute
}