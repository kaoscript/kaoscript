type Position = {
	line: Number
	column: Number
}

type Range = {
	start: Position
	end: Position
}

enum PersonKind {
    Director = 1
    Student
    Teacher
}

type SchoolPerson = Range & {
    variant kind: PersonKind {
        Student {
            name: string
        }
    }
}

export *