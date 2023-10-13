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

func greeting(person) {
	if person is SchoolPerson.Director {
		echo('Hello Director.')
	}
}