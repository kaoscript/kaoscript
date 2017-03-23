extern console

class Formatter {
	camelize(value) => value.charAt(0).toLowerCase() + value.substr(1).replace(/[-_\s]+(.)/g, (,l) => l.toUpperCase())
}

const formatter = new Formatter()

console.log(formatter.camelize('john doe'))