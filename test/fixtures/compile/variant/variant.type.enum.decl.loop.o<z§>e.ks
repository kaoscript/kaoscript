enum PersonKind {
    Director = 1
    Student
    Teacher
}

type SchoolPerson = {
    variant kind: PersonKind {
		Teacher {
			favorite: SchoolPerson(Student)
		}
    }
}