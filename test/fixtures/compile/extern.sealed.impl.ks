extern console

extern sealed class Number {
	toString(): String
}

extern sealed namespace Math {
	PI: Number
	pow(): Number
}

impl Math {
	pi: Number = Math.PI
	foo(): Number => Math.PI
}

console.log(`\(Math.pi)`)
console.log(`\(Math.foo())`)

console.log(`\(Math.pi.toString())`)
console.log(`\(Math.foo().toString())`)