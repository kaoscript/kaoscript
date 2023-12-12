enum PersonKind {
    Director = 1
    Student
    Teacher
}

type SchoolPerson = {
    variant kind: PersonKind {
        Student {
            name: String
        }
    }
}

type Group = {
	name: String
	students: SchoolPerson(Student)[]
}

type Lesson = {
	name: String
	teacher: SchoolPerson(Teacher)
	students: Group | SchoolPerson(Student)[]
}

export *