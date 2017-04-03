class Messenger {
	message() => 'Hello!'
}

class Greetings extends Messenger {
	greet(name) {
		return `\(@message())\nIt's nice to meet you, \(name).`
	}
}