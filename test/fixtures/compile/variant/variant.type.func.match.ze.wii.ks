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
        is .Teacher => "Hey Professor!"
        is .Director => "Hello Director."
        is .Student when .name == "Richard" => "Still here Ricky?"
        is .Student => `Hey, \(.name).`
    }
}