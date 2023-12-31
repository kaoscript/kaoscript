require expect: func

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
			favorite: SchoolPerson
		}
    }
}

func restore(mut student) {
	student = student:>(SchoolPerson)
}

var mut data = {
	kind: 3
	favorite: {
		kind: 2
		name: 'John'
	}
}

expect(data.favorite.kind).to.equal(2)
expect(data.favorite.kind).to.not.equal(PersonKind.Student)

echo(data)
restore(data)
echo(data)

expect(data.favorite.kind).to.not.equal(2)
expect(data.favorite.kind).to.equal(PersonKind.Student)