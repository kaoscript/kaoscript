extern console: {
	log(...args)
}

extern final class String {
}

impl String {
	lowerFirst() {
		return this.charAt(0).toLowerCase() + this.substring(1)
	}
}

let foo: string = 'HELLO!'

console.log(foo)
console.log(foo.lowerFirst())