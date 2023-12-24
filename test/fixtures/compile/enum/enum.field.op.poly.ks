bitmask WeekdayAttribute {
	Nil

	Children
	Weekend
	Working
}

enum Weekday {
    MONDAY		= (.Working)
    TUESDAY		= (.Working)
    WEDNESDAY	= (.Working + .Children)
    THURSDAY	= (.Working)
    FRIDAY		= (.Working)
    SATURDAY	= (.Working + .Weekend + .Children)
    SUNDAY		= (.Weekend + .Children)

	const attribute: WeekdayAttribute
}