extern console: {
	log(...args)
}

let foo = () => 'otto'

if bar !?= foo() {
	throw new Error()
}

console.log(foo, bar)