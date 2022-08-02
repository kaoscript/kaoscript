#![format(variables='es6')]

extern console: {
	log(...args)
}

var dyn x = 0
console.log(x)

var dyn o = {}
o.x = 30

if true {
	var dyn x = 42
	console.log(x)
	
	if true {
		var dyn x = 10
		console.log(x)
	}
	
	console.log(x)
}

console.log(x)

func foo() {
	var dyn x = 5
}