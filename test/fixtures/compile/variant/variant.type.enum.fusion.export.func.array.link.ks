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
		Teacher {
			favorite: SchoolPerson(Student)
			cards: Card(Reds)[]
		}
    }
}

enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades

	Blacks = Clubs | Spades
	Reds = Diamonds | Hearts
}

type Card = {
    variant suit: CardSuit {
	}
	rank: Number
}

func greeting(person: SchoolPerson) {
	if person is .Student {
		echo(`\(person.name)`)
	}
}

export greeting