extern console: {
	log(...args)
}

extern sealed class String {
	toLowerCase(): string
}

impl String {
	lower() as toLowerCase
}

let foo = 'HELLO!'

console.log(foo)
console.log((foo as string).lower())