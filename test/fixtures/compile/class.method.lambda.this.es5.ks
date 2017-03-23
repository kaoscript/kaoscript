#![format(functions='es5')]

extern console

class Formatter {
	camelize(value) => this.toLowerCase(value.charAt(0)) + value.substr(1).replace(/[-_\s]+(.)/g, (,l) => this.toUpperCase(l))
	toLowerCase(value) => value.toLowerCase()
	toUpperCase(value) => value.toUpperCase()
}

const formatter = new Formatter()

console.log(formatter.camelize('john doe'))