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
        is SchoolPerson.Teacher => "Hey Professor!"
        is SchoolPerson.Director => "Hello Director."
        is SchoolPerson.Student when .name == "Richard" => "Still here Ricky?"
        is SchoolPerson.Student => `Hey, \(.name).`
    }
}