require expect: func

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

expect(Weekday.WEDNESDAY.value).to.equal(2)
expect(Weekday.WEDNESDAY.index).to.equal(2)
expect(Weekday.WEDNESDAY.dayOfWeek).to.equal(3)
expect(Weekday.WEDNESDAY.printableName).to.equal('Wednesday')

expect(Weekday.values).to.eql([Weekday.MONDAY, Weekday.TUESDAY, Weekday.WEDNESDAY, Weekday.THURSDAY, Weekday.FRIDAY, Weekday.SATURDAY, Weekday.SUNDAY])
expect(Weekday.fields).to.eql(['dayOfWeek', 'printableName'])