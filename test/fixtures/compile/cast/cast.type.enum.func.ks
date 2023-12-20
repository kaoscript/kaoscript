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
	var student = getStudent() as SchoolPerson
}

func getStudent() => {
	kind: PersonKind.Student
	name: 'John'
}