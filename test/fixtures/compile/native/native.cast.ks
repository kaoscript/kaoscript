extern console: {
	log(...args)
}

extern sealed class String {
	toLowerCase(): string
}

impl String {
	lower() => this.toLowerCase()
}

var dyn foo = 'HELLO!'

console.log(foo)
console.log((foo as string).lower())