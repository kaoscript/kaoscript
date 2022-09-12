extern console: {
	log(...args)
}

extern sealed class String {
}

impl String {
	lowerFirst() {
		return this.charAt(0).toLowerCase() + this.substring(1)
	}
}

var foo: string = 'HELLO!'

console.log(foo)
console.log(foo.lowerFirst())