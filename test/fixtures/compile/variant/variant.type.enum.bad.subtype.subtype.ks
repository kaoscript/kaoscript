enum PersonKind {
    Director = 1
    Student
    Teacher
}

type SchoolPerson = {
	variant kind: PersonKind {
		Student {
			name: String
			mainTeacher: SchoolPerson(MainTeacher)
		}
	}
}