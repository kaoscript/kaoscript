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

syntime func myMacro(operator: Weekday | [Weekday, Ast(Expression)]) {
	if operator is Array {
		quote {
			#(operator[0].printableName)
			"#(operator[1])"
		}
	}
	else {
		quote {
			#(operator.printableName)
		}
	}
}

myMacro(.MONDAY)
myMacro([Weekday.SUNDAY, x != y])