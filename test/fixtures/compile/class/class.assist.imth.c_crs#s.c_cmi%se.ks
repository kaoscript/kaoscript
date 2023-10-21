class Person {
	public @name: String	= ''
}
class Student extends Person {
	public @class: String	= ''
}

class Greetings {
	greet(person: Person, message: String): String {
		return `Hello \(person.name)! \(message)`
	}
}

class MyGreetings extends Greetings {
	assist greet(person: Student, message: Number) {
		return `Hello \(person.name) of the class \(person.class)! \(message)`
	}
}