class Person {
	public @name: String	= ''
}
class Student extends Person {
	public @class: String	= ''
}

class Greetings {
	assist greet(person: Student, message) {
		return `Hello \(person.name) of the class \(person.class)! \(message)`
	}
}