enum PersonKind {
    Director = 1
    Student
    Teacher
}

type Person = {
	name: String
}

type SchoolPerson = Person & {
	favorite: SchoolPerson[] | SchoolPerson | Null
}