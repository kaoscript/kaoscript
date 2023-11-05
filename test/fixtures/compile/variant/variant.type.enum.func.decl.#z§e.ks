enum PersonKind {
    Director = 1
    Student
    Teacher
}

type SchoolPerson = {
    variant kind: PersonKind
}

func getStudent(): SchoolPerson(Student) {
    return {
		kind: .Student
		name: 'Richard'
	}
}
