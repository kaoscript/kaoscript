enum PersonKind {
    Director = 1
    Student
    Teacher
	Result
}

type Result = {
	values: SchoolPerson(Student)[] |  SchoolPerson(Teacher) | Null
}

type SchoolPerson = {
    variant kind: PersonKind {
        Student {
            name: string
        }
    }
}