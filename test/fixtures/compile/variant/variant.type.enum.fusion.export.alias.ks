type Position = {
	line: Number
	column: Number
}

enum PersonKind {
    Director = 1
    Student
    Teacher
}

type SchoolPerson = Position & {
    variant kind: PersonKind {
        Student {
            name: string
        }
    }
}

export *