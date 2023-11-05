enum PersonKind {
    Director = 1
    Student
    Teacher

	Staff = Director | Teacher
}

type Person = {
	name: String
}

type SchoolPerson = Person & {
	variant kind: PersonKind
}

func foobar(staff: SchoolPerson(Staff)) {
}