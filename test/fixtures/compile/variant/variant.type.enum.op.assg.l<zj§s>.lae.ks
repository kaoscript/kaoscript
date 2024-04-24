enum PersonKind {
    Director = 1
    Student
    Teacher
}

type Person = {
	name: string
}

type SchoolPerson = Person & {
    variant kind: PersonKind {
        Student {
            name: string
        }
		Teacher {
			favorites: SchoolPerson[]
		}
    }
}

func foobar(person) {
	var persons: SchoolPerson(Student)[] = [person]
}