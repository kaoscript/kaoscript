enum PersonKind {
    Director = 1
    Student
    Teacher
}

type SchoolPerson = {
    kind: PersonKind
	name: String
}

func foobar() {
	var student = getStudent():>(SchoolPerson)
}

func getStudent() => {
	kind: PersonKind.Student
	name: 'John'
}