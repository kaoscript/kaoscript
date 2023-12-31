require expect: func

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

func restore(mut student) {
	student = student:>(SchoolPerson)
}

var mut data = {
	kind: 2
	name: 'John'
}

expect(data.kind).to.equal(2)
expect(data.kind).to.not.equal(PersonKind.Student)

restore(data)

expect(data.kind).to.not.equal(2)
expect(data.kind).to.equal(PersonKind.Student)