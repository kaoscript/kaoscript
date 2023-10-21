enum PersonKind {
    Director = 1
    Student
    Teacher
}

type SchoolPerson = {
    variant kind: PersonKind {
		Director
        Student {
            name: string
        }
		Teacher
    }
}