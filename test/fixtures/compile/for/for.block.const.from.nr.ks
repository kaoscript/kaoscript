extern console: {
	log(...args)
}

var dyn x = 3.14

for var x from 0 to 10 by 2 {
	console.log(x)

	x += 3
}

console.log(x)