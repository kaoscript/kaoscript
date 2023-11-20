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

func foobar(name: String, ranks: []): SchoolPerson(Student) {
	return {
		kind: .Student
		name
		ranks: [rank.value for var rank in ranks]
	}
}