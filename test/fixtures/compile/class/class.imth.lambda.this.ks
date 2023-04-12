extern console

class Formatter {
	camelize(value) => this.toLowerCase(value.charAt(0)) + value.substr(1).replace(/[-_\s]+(.)/g, (_, l) => this.toUpperCase(l))
	toLowerCase(value) => value.toLowerCase()
	toUpperCase(value) => value.toUpperCase()
}

var formatter = Formatter.new()

console.log(formatter.camelize('john doe'))