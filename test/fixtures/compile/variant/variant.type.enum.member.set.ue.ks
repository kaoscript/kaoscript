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
		Teacher {
            name: string
        }
    }
}

func foobar(person: SchoolPerson(Student, Teacher)) {
	person.name = 'john'
}