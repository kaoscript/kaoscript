enum PersonKind {
    Director = 1
    Student
    Teacher
}

type Person = {
	name: String
}

type SchoolPerson = Person & {
	variant kind: PersonKind {
		Director {
			favorites: SchoolPerson(Student)[] | SchoolPerson(Teacher) | Null
		}
	}
}