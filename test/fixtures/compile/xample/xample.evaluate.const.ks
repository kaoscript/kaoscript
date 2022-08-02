#[rules(non-exhaustive)]
extern sealed class String {
	trim(): String
}

extern eval

impl String {
	evaluate() {
		var value = this.trim()

		if value.startsWith('function') || value.startsWith('{') {
			return eval('(function(){return ' + value + ';})()')
		}
		else {
			return eval(value)
		}
	}
	startsWith(value: String): Boolean => this.length >= value.length && this.slice(0, value.length) == value
}