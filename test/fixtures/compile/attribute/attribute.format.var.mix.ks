#![format(variables='es6')]

extern console: {
	log(...args)
}

var dyn x = 0
console.log(x)

if true {
	var dyn x = 42
	console.log(x)
}

console.log(x)

#[format(variables='es5')]
if true {
	var dyn x = 24
	console.log(x)
}

console.log(x)

if true {
	var dyn x = 10
	console.log(x)
}

console.log(x)