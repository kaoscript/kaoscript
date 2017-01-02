class Greetings {
	private {
		_message: string = ''
	}
	
	$create() {
		this('Hello!')
	}
	
	$create(message?) {
		this._message = message
	}
	
	$destroy() {
		this._message = null
	}
	
	greet(name) {
		return `\(this._message)\nIt's nice to meet you, \(name).`
	}
}