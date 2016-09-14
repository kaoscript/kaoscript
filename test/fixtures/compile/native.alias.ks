extern console: {
	log(...args)
}

extern final class String {
	toLowerCase() -> string
}

impl String {
	lower() as toLowerCase
}

let foo: string = 'HELLO!'

console.log(foo)
console.log(foo.toLowerCase())
console.log(foo.lower())

let bar = 'HELLO!'

console.log(bar)
console.log(bar.toLowerCase())
console.log(bar.lower())