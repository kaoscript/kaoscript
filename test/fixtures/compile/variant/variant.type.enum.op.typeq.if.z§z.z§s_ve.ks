enum PersonKind {
    Director = 1
    Student
    Teacher

	ClassMember = Student | Teacher
}

type SchoolPerson = {
    variant kind: PersonKind {
        Student {
            name: string
        }
    }
}

func foobar(person: SchoolPerson(ClassMember)) {
	if person is .Student && person.name == 'arthur' {
		echo(`\(person.name)`)
	}
}