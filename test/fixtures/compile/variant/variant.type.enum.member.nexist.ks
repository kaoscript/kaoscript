enum PersonKind {
    Director = 1
    Student
    Teacher
}

type SchoolPerson = {
    variant kind: PersonKind {
        Student {
            name: string
        }
    }
}

func foobar(student: SchoolPerson(Student)) {
	var age = student.age
}