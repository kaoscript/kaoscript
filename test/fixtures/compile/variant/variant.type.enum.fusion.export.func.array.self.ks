type Position = {
	line: Number
	column: Number
}

enum PersonKind {
    Director = 1
    Student
    Teacher
}

type SchoolPerson = Position & {
    variant kind: PersonKind {
        Student {
            name: string
        }
		Teacher {
			favorites: SchoolPerson(Student)[]
		}
    }
}

func greeting(person: SchoolPerson) {
	if person is .Student {
		echo(`\(person.name)`)
	}
}

export *