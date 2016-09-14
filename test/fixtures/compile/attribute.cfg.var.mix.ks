#![cfg(variables='es6')]

extern console: {
	log(...args)
}

let x = 0
console.log(x)

if true {
	let x = 42
	console.log(x)
}

console.log(x)

#[cfg(variables='es5')]
if true {
	let x = 24
	console.log(x)
}

console.log(x)

if true {
	let x = 10
	console.log(x)
}

console.log(x)