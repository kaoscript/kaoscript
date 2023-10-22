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

func greeting(person: SchoolPerson): String {
    return match person {
        .Teacher => "Hey Professor!"
        .Director => "Hello Director."
        .Student when .name == "Richard" => "Still here Ricky?"
        .Student => `Hey, \(.name).`
    }
}

var person = { kind: PersonKind.Teacher }

echo(greeting(person))