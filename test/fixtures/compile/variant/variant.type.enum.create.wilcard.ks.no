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

func create(kind: PersonKind): SchoolPerson {
	return {
		kind
	}
}