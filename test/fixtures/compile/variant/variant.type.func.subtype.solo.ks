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

func onlyStudent(student: SchoolPerson(Student)) {
	echo(`\(student.name)`)
}