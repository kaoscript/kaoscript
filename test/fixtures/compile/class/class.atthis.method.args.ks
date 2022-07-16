class Greetings {
	private {
		__message: string = ''
	}

	constructor() {
		this('Hello!')
	}

	constructor(@__message)

	message(prefix = '', suffix = ''): String => `\(prefix)\(@__message)\(suffix)`

	greet_01(name) {
		return `\(@message())\nIt's nice to meet you, \(name).`
	}

	greet_02(name) {
		return `\(@message(null, 'Bye!'))\nIt's nice to meet you, \(name).`
	}
}