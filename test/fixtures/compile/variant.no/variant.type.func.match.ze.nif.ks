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
        SchoolPerson.Teacher => "Hey Professor!"
        SchoolPerson.Director => "Hello Director."
        SchoolPerson.Student when .name == "Richard" => "Still here Ricky?"
        SchoolPerson.Student => `Hey, \(.name).`
    }
}