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

func foobar(person) {
	var persons: SchoolPerson(Student)[] = [person]
}