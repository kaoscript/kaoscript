enum PersonKind {
    Director = 1
    Student
    Teacher
}

type Person = {
	name: String
}

type SchoolPerson = Person & {
    variant kind: PersonKind {
        Student {
            age: string
        }
    }
}

func foobar(student: SchoolPerson(Student)) {
	var age = student.age

	echo(`\(age)`)
}