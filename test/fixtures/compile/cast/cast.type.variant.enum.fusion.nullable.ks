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
            age: Number
        }
		Teacher {
			favorite: SchoolPerson?
		}
    }
}