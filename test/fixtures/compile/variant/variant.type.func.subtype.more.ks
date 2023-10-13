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

func onlyStudentOrTeacher(person: SchoolPerson(Student, Teacher)) {
	if person is .Teacher {
		echo('teacher')
	}
	else {
		echo(`student: \(person.name)`)
	}
}