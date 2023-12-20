enum PersonKind {
    Director = 1
    Student
    Teacher
}

type Person = {
	name: string
}

type SchoolPerson = Person & {
    variant kind: PersonKind {
        Student {
            age: Number
        }
		Teacher {
			favorites: Array<SchoolPerson(Student) | Parent>
		}
    }
}

type Parent = Person & {
	children: SchoolPerson(Student)[]
}