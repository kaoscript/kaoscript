extern console: {
	log(...args)
}
extern Person: class

class Greetings {
	private _message: string = ''
	
	Greetings() {
		this('Hello!')
	}
	
	Greetings(@message)
	
	greet(name: string | number) {
		return this._message + '\nIt\'s nice to meet you, ' + name + '.'
	}
	
	greet(person: Person) {
		this.greet(person.name())
	}
}

let hello = new Greetings('Hello world!')

console.log(hello.greet('miss White'))