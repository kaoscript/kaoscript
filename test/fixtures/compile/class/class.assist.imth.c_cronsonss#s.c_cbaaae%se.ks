class Person {
	public @name: String	= ''
}
class Student extends Person {
	public @class: String	= ''
}

class Greetings {
	greet(person: Person, school: String{}?, district: String{}?, message: String): String {
		return `Hello \(person.name)! \(message)`
	}
}

class MyGreetings extends Greetings {
	assist greet(person: Student, school, district, message) {
		return `Hello \(person.name) of the class \(person.class)! \(message)`
	}
}