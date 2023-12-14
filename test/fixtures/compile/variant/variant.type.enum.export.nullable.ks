enum PersonKind {
    Director = 1
    Student
    Teacher
}

type Room = {
	name: String
}

type SchoolPerson = {
    variant kind: PersonKind {
        Student {
            name: string
			mainRoom: Room?
        }
    }
}

export *