extern console: {
	log(...args)
}
extern Person: class

class Greetings {
	private _message: string = ''

	constructor() {
		this('Hello!')
	}

	constructor(@message)

	greet(name: string | number) {
		return this._message + '\nIt\'s nice to meet you, ' + name + '.'
	}

	greet(person: Person) {
		this.greet(person.name())
	}
}

var dyn hello = Greetings.new('Hello world!')

console.log(hello.greet('miss White'))