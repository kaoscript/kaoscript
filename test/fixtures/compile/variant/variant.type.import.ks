import './variant.type.export.ks'

func greeting(person: SchoolPerson): String {
    return match person {
        .Teacher => "Hey Professor!"
        .Director => "Hello Director."
        .Student when .name == "Richard" => "Still here Ricky?"
        .Student => `Hey, \(.name).`
    }
}

var person: SchoolPerson = { kind: .Student, name: 'Richard' }

echo(greeting(person))