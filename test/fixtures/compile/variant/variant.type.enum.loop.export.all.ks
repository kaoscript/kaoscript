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
			favorite: SchoolPerson(Student)
		}
    }
}

func greeting(person: SchoolPerson) {
	if person is .Student {
		echo(`\(person.name)`)
	}
}

export *