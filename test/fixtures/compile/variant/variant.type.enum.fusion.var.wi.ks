enum PersonKind {
    Director = 1
    Student
    Teacher
}

type Person = {
	name: String
}

type SchoolPerson = Person & {
	variant kind: PersonKind
}

var person: SchoolPerson = { kind: .Student, name: 'Richard' }