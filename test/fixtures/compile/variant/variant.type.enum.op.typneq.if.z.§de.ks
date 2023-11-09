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

func greeting(person: SchoolPerson) {
	if person is not .Director {
		echo('Not Director?')
	}
}