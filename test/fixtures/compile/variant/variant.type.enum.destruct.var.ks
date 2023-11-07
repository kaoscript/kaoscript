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

func foobar(person: SchoolPerson(Student)) {
	var { name } = person

	echo(`\(name)`)
}