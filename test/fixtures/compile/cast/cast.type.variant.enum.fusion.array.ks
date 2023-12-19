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
            name: string
        }
		Teacher {
			favorites: SchoolPerson[]
		}
    }
}

func restore(mut student) {
	student = student as SchoolPerson
}

var mut data = {
	kind: 3
	favorites: [{
		kind: 2
		name: 'John'
	}]
}

expect(data.favorites[0].kind).to.equal(2)
expect(data.favorites[0].kind).to.not.equal(PersonKind.Student)

echo(data)
restore(data)
echo(data)

expect(data.favorites[0].kind).to.not.equal(2)
expect(data.favorites[0].kind).to.equal(PersonKind.Student)